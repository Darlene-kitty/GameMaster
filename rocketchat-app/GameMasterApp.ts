import {
    IAppAccessors,
    IConfigurationExtend,
    IHttp,
    ILogger,
    IModify,
    IPersistence,
    IRead,
} from '@rocket.chat/apps-engine/definition/accessors';
import { App } from '@rocket.chat/apps-engine/definition/App';
import { IAppInfo } from '@rocket.chat/apps-engine/definition/metadata';
import { ISlashCommand, SlashCommandContext } from '@rocket.chat/apps-engine/definition/slashcommands';

// ─── Types ────────────────────────────────────────────────────────────────────

interface CommandResult {
    title: string;
    text: string;
}

type ModAction = 'warn' | 'kick' | 'ban';

const VALID_MOD_ACTIONS: ReadonlySet<string> = new Set<ModAction>(['warn', 'kick', 'ban']);

const DICE_REGEX = /^(\d+)d(\d+)(?:\+(\d+))?$/i;

const MAX_DICE_COUNT = 100;
const MAX_DICE_FACES = 1000;

// ─── Command handlers ─────────────────────────────────────────────────────────

function handleHelp(): CommandResult {
    return {
        title: "COMMANDES DE L'ARCHIVE",
        text:
            'Utilisez les commandes slash suivantes pour interagir avec le monde :\n\n' +
            '```\n/gm roll [dice]\nExemple: 2d20 + 4\n```\n\n' +
            '```\n/gm poll [desc]\nLancer un vote de groupe\n```\n\n' +
            '```\n/gm remind [temps] [message]\nProgrammer un rappel système.\n```\n\n' +
            '```\n/gm mod [action] [user]\nCommandes de modération (kick, ban, warn).\n```\n\n' +
            '📖 [Documentation Rocket.Chat](https://docs.rocket.chat)',
    };
}

function handleRoll(args: string[], username: string): CommandResult {
    const diceArg = args.slice(1).join('').replace(/\s/g, '') || '1d20';
    const match = diceArg.match(DICE_REGEX);

    if (!match) {
        return {
            title: 'ERREUR SYNTAXE',
            text: '❌ Format invalide. Utilisez : `/gm roll 2d20` ou `/gm roll 1d20+4`',
        };
    }

    const nb = parseInt(match[1], 10);
    const faces = parseInt(match[2], 10);
    const bonus = match[3] ? parseInt(match[3], 10) : 0;

    if (nb < 1 || nb > MAX_DICE_COUNT) {
        return {
            title: 'ERREUR VALEUR',
            text: `❌ Le nombre de dés doit être entre 1 et ${MAX_DICE_COUNT}.`,
        };
    }

    if (faces < 2 || faces > MAX_DICE_FACES) {
        return {
            title: 'ERREUR VALEUR',
            text: `❌ Le nombre de faces doit être entre 2 et ${MAX_DICE_FACES}.`,
        };
    }

    const rolls: number[] = Array.from({ length: nb }, () => Math.floor(Math.random() * faces) + 1);
    const rawTotal = rolls.reduce((sum, r) => sum + r, 0);
    const total = rawTotal + bonus;
    const isCrit = rawTotal === nb * faces;

    return {
        title: 'LANCEMENT DE DÉS',
        text:
            `🎲 **${username}** lance \`${nb}d${faces}${bonus ? ` + ${bonus}` : ''}\`\n\n` +
            `\`\`\`\nRésultats bruts: [ ${rolls.join(', ')} ]\n\`\`\`\n` +
            `> **TOTAL : ${total}**${isCrit ? ' ✨ CRITIQUE !' : ''}`,
    };
}

function handlePoll(args: string[]): CommandResult {
    const fullText = args.slice(1).join(' ').trim();
    const parts = fullText.split('|').map((p) => p.trim()).filter(Boolean);

    if (!parts.length || !parts[0]) {
        return {
            title: 'ERREUR SYNTAXE',
            text: '❌ Format : `/gm poll Question ? | Option 1 | Option 2`',
        };
    }

    const [question, ...options] = parts;
    const NUMBER_EMOJIS = ['1️⃣', '2️⃣', '3️⃣', '4️⃣', '5️⃣', '6️⃣', '7️⃣', '8️⃣', '9️⃣'];

    const optionLines =
        options.length > 0
            ? options.map((opt, i) => `${NUMBER_EMOJIS[i] ?? `${i + 1}.`} ${opt}`).join('\n')
            : '_Réagissez avec 👍 ou 👎 pour voter !_';

    return {
        title: 'SONDAGE DU GROUPE',
        text: `📊 **Question : ${question}**\n\n${optionLines}`,
    };
}

function handleRemind(args: string[]): CommandResult {
    const time = args[1] || '10m';
    const message = args.slice(2).join(' ') || 'Rappel';

    return {
        title: 'RAPPEL PROGRAMMÉ',
        text:
            `⏰ **Dans ${time}**\n\n📝 "${message}"\n\n` +
            '_⚠️ Note : cette commande affiche uniquement le rappel. La notification automatique nécessite un scheduler externe._',
    };
}

function handleMod(args: string[]): CommandResult {
    const action = (args[1] || 'warn').toLowerCase();
    const target = args[2] || '@utilisateur';
    const reason = args.slice(3).join(' ') || 'Aucune raison spécifiée.';

    if (!VALID_MOD_ACTIONS.has(action)) {
        return {
            title: '🛡️ ACTION DE MODÉRATION',
            text: '❌ Action invalide. Spécifiez `warn`, `kick` ou `ban`.',
        };
    }

    return {
        title: '🛡️ ACTION DE MODÉRATION',
        text: `L'action **${action.toUpperCase()}** a été appliquée à **${target}**.\n\n> **Motif :** ${reason}`,
    };
}

function handleUnknown(subcommand: string): CommandResult {
    return {
        title: "SYSTÈME D'ARCHIVE",
        text: `Commande \`${subcommand}\` non reconnue.\nFaites \`/gm help\` pour le manuel.`,
    };
}

// ─── Slash command ─────────────────────────────────────────────────────────────

class GameMasterCommand implements ISlashCommand {
    public command: string;
    public i18nParamsExample = 'help | roll | poll | remind | mod';
    public i18nDescription = 'Commandes du GameMaster';
    public providesPreview = false;

    constructor(command = 'gm') {
        this.command = command;
    }

    public async executor(
        context: SlashCommandContext,
        _read: IRead,
        modify: IModify,
        _http: IHttp,
        _persis: IPersistence,
    ): Promise<void> {
        const args = context.getArguments();
        const subcommand = (args[0] || 'help').toLowerCase();
        const sender = context.getSender();
        const room = context.getRoom();

        const result = this.dispatch(subcommand, args, sender.username);

        const builder = modify
            .getCreator()
            .startMessage()
            .setRoom(room)
            .setUsernameAlias('GAMEMASTER BOT')
            .setEmojiAvatar(':robot:');

        builder.addAttachment({
            color: '#e67e22',
            title: { value: result.title },
            text: result.text,
        });

        await modify.getCreator().finish(builder);
    }

    private dispatch(subcommand: string, args: string[], username: string): CommandResult {
        switch (subcommand) {
            case 'help':    return handleHelp();
            case 'roll':    return handleRoll(args, username);
            case 'poll':    return handlePoll(args);
            case 'remind':  return handleRemind(args);
            case 'mod':
            case 'moderation': return handleMod(args);
            default:        return handleUnknown(subcommand);
        }
    }
}

// ─── App entry point ───────────────────────────────────────────────────────────

export class GameMasterApp extends App {
    constructor(info: IAppInfo, logger: ILogger, accessors: IAppAccessors) {
        super(info, logger, accessors);
    }

    public async initialize(configuration: IConfigurationExtend): Promise<void> {
        await configuration.slashCommands.provideSlashCommand(new GameMasterCommand('gm'));
        await configuration.slashCommands.provideSlashCommand(new GameMasterCommand('gamemaster'));
        this.getLogger().log('🎮 GameMaster App initialisée !');
    }
}
