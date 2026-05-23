fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### public_beta

```sh
[bundle exec] fastlane public_beta
```

Upload to TestFlight for Live Release

### make_github_release

```sh
[bundle exec] fastlane make_github_release
```

Make github release

### get_git_change_log

```sh
[bundle exec] fastlane get_git_change_log
```

Get git change log

----


## iOS

### ios compile_check

```sh
[bundle exec] fastlane ios compile_check
```

Compile the app without building or packaging

### ios compile

```sh
[bundle exec] fastlane ios compile
```

Compile the app without building or packaging

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Generate new localized screenshots

### ios build

```sh
[bundle exec] fastlane ios build
```

Build the app for App Store submission

### ios build_staging

```sh
[bundle exec] fastlane ios build_staging
```

Build the staging app for App Store submission

### ios tests

```sh
[bundle exec] fastlane ios tests
```

Run tests

### ios testflight_alpha

```sh
[bundle exec] fastlane ios testflight_alpha
```

Upload Staging Build to TestFlight for internal testing

### ios tag_github

```sh
[bundle exec] fastlane ios tag_github
```

Create and push tag v.<marketing_version> from Xcode target AgentOrange at current commit. FASTLANE_FORCE_PUBLIC_BETA_TAG=true replaces existing local tag (--force).

### ios public_beta

```sh
[bundle exec] fastlane ios public_beta
```

Upload to TestFlight for public beta testing

### ios bump

```sh
[bundle exec] fastlane ios bump
```

Increment build number

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Lint code

### ios distribute_alpha

```sh
[bundle exec] fastlane ios distribute_alpha
```

Distribute the app to Firebase App Distribution

### ios slack_notify

```sh
[bundle exec] fastlane ios slack_notify
```

Message to slack

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
