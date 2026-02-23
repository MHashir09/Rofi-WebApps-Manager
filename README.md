<p align="center">
  <img src="icons/webapp-manager.png" width="80"/>
  <h1 align="center">Rofi WebApps Manager</h1>
</p>

A rofi-based web app manager for Chromium-based browsers. Create, remove and modify web apps from a clean rofi menu.

<video src="https://github.com/user-attachments/assets/969f8745-be92-4f6a-acdf-ee91bc5d2d11" controls></video>

## Dependencies

- `rofi` or `rofi-wayland`
- `curl`
- `dunst`
- A Chromium-based browser (default: `helium-browser`)

## Installation

### AUR
```bash
paru -S rofi-webapps-manager
```

### Manual
```bash
git clone https://github.com/MHashir09/Rofi-WebApps-Manager
cd Rofi-WebApps-Manager
chmod +x webapp-manager.sh
cp webapp-manager.sh ~/.local/bin/webapp-manager
cp webapp-manager.desktop ~/.local/share/applications/
mkdir -p ~/.local/share/icons/webapps
cp icons/webapp-manager.png ~/.local/share/icons/
```

## Usage

Launch via your app launcher or bind it to a keybind:

```bash
webapp-manager
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
- Helium Browser
- Chromium
- Ungoogled Chromium
- Brave
- Vivaldi
- Google Chrome
- Microsoft Edge

> [!NOTE]
> If you use a different browser than the ones listed above then you need to either manually add it or create an issue about it and I will add it for sure.

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

Please ⭐ this repository if you found this helpful. Made by [MHIA (MHashir09)](https://github.com/MHashir09) . Thankyou for visiting :3
