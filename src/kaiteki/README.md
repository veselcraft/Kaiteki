# ![Kaiteki](assets/readme-banner.svg)

[![Build status](https://img.shields.io/github/workflow/status/Kaiteki-Fedi/Kaiteki/Build%20&%20Deploy)](https://github.com/Kaiteki-Fedi/Kaiteki/actions/workflows/ci.yml) [![CodeFactor](https://www.codefactor.io/repository/github/kaiteki-fedi/kaiteki/badge)](https://www.codefactor.io/repository/github/kaiteki-fedi/kaiteki)
[![Translation status](https://wl.craftplacer.moe/widgets/kaiteki/-/app/svg-badge.svg)](https://wl.craftplacer.moe/engage/kaiteki/)

A [快適 (kaiteki)](http://takoboto.jp/?w=1200120) Fediverse client for microblogging instances, made with [Flutter](https://flutter.dev/) and [Dart](https://dart.dev/).

Currently, Kaiteki is still in a **proof-of-concept/alpha stage**, with simple Mastodon/Pleroma and Misskey support, future backends could follow. See ["What's working, what's missing?"](#whats-working-whats-missing).

## Screenshots

<table>
    <td><img src="assets/screenshots/misskey-feed-phone.jpg" width="110" alt="Screenshot of a Misskey feed inside Kaiteki on a phone"></td>
    <td><img src="assets/screenshots/pleroma-user-tablet.jpg" width="400" alt="Screenshot of an user inside Kaiteki on a tablet"></td>
</table>

## Platforms & Releases

If you want to try out Kaiteki, there are automatic builds available for use.

<table>
    <tr>
        <th></th>
        <th>Web<br>(recommended)</th>
        <th>Windows</th>
        <th>Linux</th>
        <th>Android</th>
        <th>macOS</th>
        <th>iOS</th>
    </tr>
    <tr>
        <th>Binaries</th>
        <td rowspan=2><a href="https://kaiteki.craftplacer.moe/">Visit web version</a></td>
        <td><a href="https://nightly.link/Kaiteki-Fedi/Kaiteki/workflows/windows/master/windows.zip">Download latest binaries</a></td>
        <td><a href="https://nightly.link/Kaiteki-Fedi/Kaiteki/workflows/linux/master/linux.zip">Download latest binaries</a></td>
        <td rowspan=2><a href="https://nightly.link/Kaiteki-Fedi/Kaiteki/workflows/android/master/android.zip">Download latest APK</a></td>
        <td colspan=2 rowspan=2>Not supported.</td>
    </tr>
    <tr>
        <th>Packages / Installers</th>
        <td>No reliable packaging yet.<br><a href="https://github.com/Kaiteki-Fedi/Kaiteki/issues/63">Help us!</a></td>
        <td>
            <a href="https://nightly.link/Kaiteki-Fedi/Kaiteki/workflows/linux/master/appimage.zip">AppImage</a>
            <br><br>
            <a href="https://github.com/Kaiteki-Fedi/Kaiteki/issues/62">Help us package for more platforms!</a>
        </td>
    </tr>
</table>


## What's working, what's missing?

Currently, Kaiteki only allows viewing timelines, making text posts and viewing users.

Most important API calls for Misskey, Mastodon/Pleroma are already implemented but need a UI implementation.

Other features that are missing are extensive settings, unit tests, and many other things. **If you'd like to contribute, feel free to do so.**

## Compiling Kaiteki

Depending on your platform you might have to take extra steps.
See [this page for steps on compiling for desktop](https://docs.flutter.dev/desktop), and [this page for steps on compiling for web](https://flutter.dev/docs/get-started/web).

```sh
flutter upgrade # upgrade flutter to its latest version
flutter pub get # get packages

# run
flutter run

# ... or compile a release build
flutter build apk --release
flutter build windows --release
flutter build linux --release
flutter build web --release
```
