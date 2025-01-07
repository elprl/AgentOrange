<p align="center" >
  <img src="https://github.com/elprl/AgentOrange/blob/8dd2bd885fa40061886cf6213d15e13898c4037c/AgentOrange/logo.png" title="Agent Orange logo" float=left>
</p>

![Static Badge](https://img.shields.io/badge/platform-macOS_(catalyst)_%7C_iOS_%7C_iPadOS-blue)
![Static Badge](https://img.shields.io/badge/version-1.3.0-blue)

This application is an AI Agent which explores workflows for enhancing the productivity of coders. It can use local LLMs or frontier models from OpenAI, Claude and Gemini (via APIs).

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