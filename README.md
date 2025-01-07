<p align="center" >
  <img src="https://github.com/elprl/AgentOrange/blob/811f14842c3dee98876d82847515ab4a187677f0/logo.png" title="Agent Orange logo" float=left>
</p>

[![Platform](https://img.shields.io/badge/Platform-macOS_(catalyst)_%7C_iOS_%7C_iPadOS-orange)](https://github.com/elprl/AgentOrange)
[![Swift Version](https://img.shields.io/badge/Swift-6.0-orange)](https://github.com/elprl/AgentOrange)
[![Version](https://img.shields.io/badge/Version-1.3.0-orange)](https://github.com/elprl/AgentOrange)


This application is an AI Agent used internally by [Tapdigital Ltd](https://www.tapdigital.com) and now released for the benefit of the community. It explores workflows for enhancing the productivity of coders. The app utilises local LLMs or frontier models from OpenAI, Claude and Gemini (via APIs). You setup commands (AI prompts you use regularly) then configure the running of those commands into a workflow of your chosing.

<p align="center" >
  <img src="https://github.com/elprl/AgentOrange/blob/811f14842c3dee98876d82847515ab4a187677f0/screenshot.jpg" title="Agent Orange screenshot" float=left>
</p>

### Installing & Running

- Open the project in Xcode.
- Add a `Config.xcconfig` in the same directory as the `Info.plist` file.
- Add your debug API Keys as follows:
```
MOCK_OPENAI_TOKEN=sk-wZktiPK..Qh5VdbP
MOCK_CLAUDE_TOKEN=sk-ant-api03-cdvPm57...AbwIhAAA
MOCK_GEMINI_TOKEN=AIzaSyA..OxVnboD-7w

```
- Add your signing Team in the target Signing & Capabilities section.
- Optional change the bundle ID.
- Run on 'My Mac' or your connected devices.