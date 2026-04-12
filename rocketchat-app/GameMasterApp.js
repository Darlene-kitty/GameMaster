"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GameMasterApp = void 0;
const App_1 = require("@rocket.chat/apps-engine/definition/App");
class GameMasterApp extends App_1.App {
    constructor(info, logger, accessors) {
        super(info, logger, accessors);
    }
}
exports.GameMasterApp = GameMasterApp;
