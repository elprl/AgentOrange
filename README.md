<p align="center" >
  <img src="https://github.com/elprl/AgentOrange/blob/811f14842c3dee98876d82847515ab4a187677f0/logo.png" title="Agent Orange logo" float=left>
</p>

[![Platform](https://img.shields.io/badge/Platform-macOS_(catalyst)_|_iOS_|_iPadOS-orange)](https://github.com/elprl/AgentOrange)
[![SwiftUI](https://img.shields.io/badge/Built_with-SwiftUI_|_SwiftData-orange)](https://github.com/elprl/AgentOrange)
[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange)](https://github.com/elprl/AgentOrange)
[![Version](https://img.shields.io/badge/Version-1.3.0-orange)](https://github.com/elprl/AgentOrange)


This application is a rapid prototype AI Agent used internally by [Tapdigital](https://www.tapdigital.com) and now released for the benefit of the community. It explores workflows for enhancing the productivity of coders. The app utilises local LLMs or frontier models from OpenAI, Claude and Gemini (via APIs). You setup commands (AI prompts you use regularly) then configure the running of those commands into a workflow of your chosing.

(If you would like to hire tapdigital, contact us [here](https://tapdigital.com/contact.html)).

<p align="center" >
  <img src="https://github.com/elprl/AgentOrange/blob/811f14842c3dee98876d82847515ab4a187677f0/screenshot.jpg" title="Agent Orange screenshot" float=left>
</p>

### Installing

- Open the project in Xcode.
- Add a `Config.xcconfig` file in the same directory as the `Info.plist` file. (Optional)
- Add to this file your debug API Keys as follows:
```
MOCK_OPENAI_TOKEN=sk-wZktiPK..Qh5VdbP
MOCK_CLAUDE_TOKEN=sk-ant-api03-cdvPm57...AbwIhAAA
MOCK_GEMINI_TOKEN=AIzaSyA..OxVnboD-7w
```
- Otherwise you can just use the settings UI.
- Add your signing Team in the target Signing & Capabilities section.
- Optional change the bundle ID.

### Running
- Run on 'My Mac' or your connected devices through Xcode.
- Or create an archive.
- For local LLMs, recommend using [LM Studio](https://lmstudio.ai/). Just remember to start the server and load a model. Should also work with [Ollama](https://ollama.com/) or [gpt4all](https://www.nomic.ai/gpt4all) but not tested.