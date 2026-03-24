<p align="center">
  <img src="icons/webapp-manager.png" width="80"/>
  <h1 align="center">Rofi WebApps Manager</h1>
</p>

A rofi-based web app manager for Chromium-based browsers. Create, remove and modify web apps from a clean rofi menu.

## Demonstration

The showcase videos below demonstrate each of the three main options of this app.

### Installing Web Applications

<video src="https://github.com/user-attachments/assets/774e2574-70e1-4186-995e-941ec71a9ecb" controls></video>

### Removing Web Applications

<video src="https://github.com/user-attachments/assets/5835e804-16f7-4209-b822-86c9303464f8" controls></video>

### Modifying Web Applications

<video src="https://github.com/user-attachments/assets/a9c05630-f03c-4f87-9a3d-08ad33bc77a6" controls></video>


> [!NOTE]
> The theme of the menu may differ for you as it depends on your own personal rofi configuration but the functionality will remain same nonetheless.

## Dependencies

- [`rofi`](https://github.com/davatorium/rofi/blob/next/INSTALL.md#install-distribution) ( For the menu itself )
- [`curl`](https://everything.curl.dev/install/index.html) ( To pull icons of webapps )
- [`dunst`](https://dunst-project.org/documentation/installation/)  ( For notifications regarding different actions )
- A Chromium-based browser ( default: [`helium-browser`](https://helium.computer/) or see [Change the default browser section for the list of supported browsers](https://github.com/MHashir09/Rofi-WebApps-Manager?tab=readme-ov-file#configuration)

## Installation

### AUR
```bash
paru -S rofi-webapps-manager
```

### Manual

> [!WARNING]
> For manual installation, please first make sure you have all the aforementioned dependencies installed on your system.
> Just click on the dependency's names and it should redirect you to their installation pages.

```bash
git clone https://github.com/MHashir09/Rofi-WebApps-Manager.git
cd Rofi-WebApps-Manager
chmod +x webapp-manager.sh
cp webapp-manager.sh ~/.local/bin/webapp-manager
cp webapp-manager.desktop ~/.local/share/applications/
mkdir -p ~/.local/share/icons/webapps
cp icons/webapp-manager.png ~/.local/share/icons/
```

## Usage

Launch via your app launcher or bind it to a keybind or via shell by:

```bash
webapp-manager
```
To check the version of package:

```bash
webapp-manager -v # or webapp-manager --version
```

### Options

| Option | Description |
|--------|-------------|
| Summon Webapp | Create a new web app |
| Remove Webapp | Remove an existing web app |
| Modify Webapp | Change name, URL or migrate browser |

## Configuration

### Changing the default browser

Open **Web Apps Manager ➤ Modify WebApps ➤ Migrate WebApps** and select your browser from the list. This permanently updates the default browser for all future webapps.

Supported browsers:
- [Helium Browser](https://helium.computer/)
- [Google Chrome](https://www.google.com/chrome/)
- [Ungoogled Chromium](https://ungoogled-software.github.io/)
- [Brave](https://brave.com/)
- [Vivaldi](https://vivaldi.com/)
- [Microsoft Edge](https://www.microsoft.com/en-us/edge/?form=MA13FJ)

> [!NOTE]
> If you use a different browser than the ones listed above then you need to either manually add it or create an issue about it and I will add it for sure.

## To Do List

These are some features, optimizations or improvements I plan to add in the near future. As this is a hobby project, I will add these whenever I have the time to do so but any of you is welcome to contribute by making a PR for any of these. Read below for instructions on contributing !

- Improve the UX
- Firefox and gecko based browser's support via PWA
- Allow users to choose a custom icon of webapps
- Allow users to create backups of all the installed webapps and allow them to add them back via the backup incase of a new install
- More confirmation messages to avoid mishaps

If you want some other quality of life features to be added create an issue about it and I will add it or just make a PR about it yourself. I am down for anything as long as it's meaningful !

## Contributing

Contributions are welcome! Here's how you can help:

- **Fork** the repo and submit a pull request for bug fixes or new features
- **Create an issue** if you find a bug or want to request a feature
- **Request a browser** if your Chromium-based browser isn't in the list — open an issue and I'll add it

> [!NOTE]
> Please keep pull requests focused and minimal — one fix or feature per PR.

## License

GPL-3.0 — see [LICENSE](LICENSE)

---

Please ⭐ this repository if you found this helpful. Made by [MHIA](https://github.com/MHashir09) . Thankyou for visiting :3
