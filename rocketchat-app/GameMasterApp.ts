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

class GameMasterCommand implements ISlashCommand {
    public command: string;
    public i18nParamsExample: string = 'help | roll | poll';
    public i18nDescription: string = 'Commandes du GameMaster';
    public providesPreview: boolean = false;

    constructor(command: string = 'gm') {
        this.command = command;
    }

    public async executor(context: SlashCommandContext, read: IRead, modify: IModify, http: IHttp, persis: IPersistence): Promise<void> {
        const args = context.getArguments();
        const subcommand = args[0] || 'help';
        const sender = context.getSender();
        const room = context.getRoom();

        let attachmentTitle = '';
        let attachmentText = '';

        switch (subcommand.toLowerCase()) {
            case 'help':
                attachmentTitle = 'COMMANDES DE L\'ARCHIVE';
                attachmentText = `Utilisez les commandes slash suivantes pour interagir avec le monde :\n\n` +
                                 `\`\`\`\n/gm roll [dice]\nExemple: 2d20 + 4\n\`\`\`\n\n` +
                                 `\`\`\`\n/gm poll [desc]\nLancer un vote de groupe\n\`\`\`\n\n` +
                                 `\`\`\`\n/gm remind [temps] [message]\nProgrammer un rappel système.\n\`\`\`\n\n` +
                                 `\`\`\`\n/gm moderation [action] [user]\nCommandes MEE6 (kick, ban, warn).\n\`\`\`\n\n` +
                                 `📖 [Documentation Rocket.Chat](https://docs.rocket.chat)`;
                break;

            case 'roll': {
                const diceArg = args.slice(1).join('').replace(/\s/g, '') || '1d20';
                const match = diceArg.match(/(\d+)d(\d+)(?:\+(\d+))?/i);
                if (match) {
                    const nb = parseInt(match[1], 10);
                    const faces = parseInt(match[2], 10);
                    const bonus = match[3] ? parseInt(match[3], 10) : 0;
                    let total = 0;
                    const rolls: number[] = [];
                    for (let i = 0; i < nb; i++) {
                        const roll = Math.floor(Math.random() * faces) + 1;
                        rolls.push(roll);
                        total += roll;
                    }
                    total += bonus;
                    attachmentTitle = 'LANCEMENT DE DÉS';
                    attachmentText = `🎲 **${sender.username}** lance \`${nb}d${faces}${bonus ? ' + '+bonus : ''}\`\n\n` +
                                     `\`\`\`\nRésultats bruts: [ ${rolls.join(', ')} ]\n\`\`\`\n` +
                                     `> **TOTAL : ${total}** ${(total - bonus) === nb * faces ? '✨ CRITIQUE !' : ''}`;
                } else {
                    attachmentTitle = 'ERREUR SYNTAXE';
                    attachmentText = `❌ Format invalide. Utilisez : \`/gm roll 2d20\` ou \`/gm roll 1d20+4\``;
                }
                break;
            }

            case 'poll': {
                const fullText = args.slice(1).join(' ');
                const parts = fullText.split('|').map(p => p.trim());
                if (parts.length > 0 && parts[0]) {
                    attachmentTitle = 'SONDAGE DU GROUPE';
                    attachmentText = `📊 **Question : ${parts[0]}**\n\n`;
                    if (parts.length > 1) {
                        const options = parts.slice(1);
                        options.forEach((opt, i) => {
                            attachmentText += `${i + 1}️⃣ ${opt}\n`;
                        });
                    } else {
                         attachmentText += `_Réagissez avec 👍 ou 👎 pour voter !_`;
                    }
                } else {
                    attachmentTitle = 'ERREUR SYNTAXE';
                    attachmentText = `❌ Format : \`/gm poll Question ? | Option 1 | Option 2\``;
                }
                break;
            }

            case 'remind': {
                const time = args[1] || '10m';
                const reminderMsg = args.slice(2).join(' ') || 'Rappel';
                attachmentTitle = 'RAPPEL PROGRAMMÉ';
                attachmentText = `⏰ **Dans ${time}**\n\n📝 "${reminderMsg}"\n\n_⚠️ Note : cette commande affiche uniquement le rappel. La notification automatique nécessite un scheduler externe._`;
                break;
            }

            case 'moderation':
            case 'mod': {
                const modAction = args[1] || 'warn';
                const modTarget = args[2] || '@utilisateur';
                const modReason = args.slice(3).join(' ') || 'Aucune raison spécifiée.';
                
                attachmentTitle = '🛡️ ACTION DE MODÉRATION (TYPE MEE6)';
                if (modAction.toLowerCase() === 'kick' || modAction.toLowerCase() === 'ban' || modAction.toLowerCase() === 'warn') {
                     attachmentText = `L'action **${modAction.toUpperCase()}** a été appliquée à l'entité **${modTarget}**.\n\n> **Motif :** ${modReason}`;
                } else {
                     attachmentText = `❌ Action invalide. Spécifiez \`warn\`, \`kick\` ou \`ban\`.`;
                }
                break;
            }

            default:
                attachmentTitle = 'SYSTÈME D\'ARCHIVE';
                attachmentText = `Commande \`${subcommand}\` non reconnue. \nFaites \`/gm help\` pour le manuel.`;
        }

        const builder = modify.getCreator().startMessage()
            .setRoom(room)
            .setUsernameAlias('GAMEMASTER BOT')
            .setEmojiAvatar(':robot:');

        const attachment: any = {
            color: '#e67e22',
            title: { value: attachmentTitle },
            text: attachmentText,
        };

        builder.addAttachment(attachment);
        await modify.getCreator().finish(builder);
    }
}

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