# CONTRIBUTING

We love pull requests from everyone. By participating in this project, you agree to abide by the thoughtbot [code of conduct](https://thoughtbot.com/open-source-code-of-conduct).

## Quick guide

### Fork the repo

Here's a quick guide:

1. Fork the repo.
1. `git clone <fork_url>`
1. `cd flutter_image_editor`
1. `dart pub global activate melos`
1. melos bootstrap

### Android

Open `flutter_image_editor/image_editor/example/android` in Android Studio.

Or open `flutter_image_editor_common/example/android` in Android Studio.

Edit `image_editor_common/android/**.kotlin` files.

### iOS

```sh
open flutter_image_editor/image_editor/example/ios/Runner.xcworkspace
```

Then the project will be opened in Xcode.

Edit the `Pods/Development Pods/image_editor_common/**.m` files.

### macOS

```sh
open flutter_image_editor/image_editor/example/macos/Runner.xcworkspace
```

Edit the `Pods/Development Pods/image_editor_common/**.m` files.

### Open Harmony

Open `flutter_image_editor/image_editor/example/ohos` in DevEco Studio.

## CHANGELOG

When contributing to this project, please follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for your commit messages. This helps us automatically generate the CHANGELOG.

### Commit Message Format

Each commit message should be structured as follows:

```log
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: A new feature (correlates with MINOR version)
- `fix`: A bug fix (correlates with PATCH version)
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Breaking Changes

- Add `!` after the type/scope: `feat!: breaking change`
- Or add `BREAKING CHANGE:` in the footer

### Examples

```log
feat(android): add image rotation support

fix(ios): resolve memory leak in image processing

docs: update installation instructions

feat!: change API interface
BREAKING CHANGE: new API is not compatible with previous versions
```

## For adminer of repo

### Generate changelog and bump version

```sh
melos version
```

The command will generate changelog and bump version.

Next:

```sh
git push # to publish code to github
git push --tags # to publish tags to github
# or
git push --follow-tags # the command will push code and tags to github
```

If the package is the main package, you should create new release on github.

When the tag pushed to github, the action will publish the package to pub.dev.

### Publish a new version manually

Use git tag to publish a new version to `pub.dev`.

```sh
git tag <package name>-v<version>

# Such as:

git tag image_editor-v1.4.0
git push --tags
```

Or use [github release new](https://github.com/fluttercandies/flutter_image_editor/releases/new) page to create a new release.

The support package name is define in [publish.py](https://github.com/fluttercandies/flutter_image_editor/blob/main/publish.py#L7)

Now they are `image_editor`, `image_editor_common`, `image_editor_platform_interface` and `image_editor_ohos`.
