# 🏚️ World Decay

## ⚠️ IMPORTANT WARNING

**This mod is still under active development.**

It is currently a work in progress, so you may experience bugs, unexpected behavior, or performance issues. We are not professional modders; we are passionate players doing our best to create a high-quality experience.

✅ **Contributions are welcome.**
If you want to help improve the mod, feel free to report bugs, suggest features, or submit pull requests on our GitHub. If you'd like to translate the mod into your language, you're welcome to contribute as well:

[https://github.com/Ledezma28-1/WorldDecay-B42](https://github.com/Ledezma28-1/WorldDecay-B42)

## 📦 What is this mod?

**World Decay** overrides the base map appearance to reflect **years of urban decay**. When each map chunk loads, the mod applies its generators **procedurally**: vegetation (trees, bushes, grass, vines), structural decay (cracks, burned walls, broken doors and windows, bent fences), trash, and barricades.

Uses a **persistent chunk cache** to skip already-visited areas and a **batched dispatcher** to avoid lag spikes. Includes cleaning tools and **full sandbox control** over every element.

## 🌟 Key Features

- **Vegetation System:** Trees, bushes, grass, and vines with configurable percentages via sandbox.
- **Urban Decay:** Cracked roads, burned walls, broken doors and windows, bent and broken fences.
- **Barricades:** Remnants of desperate last stands found throughout the world.
- **Trash & Debris:** Accumulated garbage that reinforces the passage of time.
- **Cleaning System:** Right-click menu to remove vegetation and clear areas for rebuilding.
- **Full Sandbox Customization:** Every element can be tuned, enabled, or disabled.

## ⚡ Performance Notice

**⚠️ IMPORTANT:** This mod significantly alters the world generation and adds a large amount of objects to every loaded chunk. As a result, it may **negatively impact performance** on lower-end systems. This is completely normal due to how Project Zomboid handles object rendering and is not a bug.

**🕐 First Load:** It is completely normal to experience some lag during the first few seconds after loading into the world, as vegetation and objects are being generated across all visible chunks. Give it a moment — performance will stabilize once the initial generation pass completes.

Recommendations:
- Allocate more RAM to the game if possible.
- Reduce vegetation percentages in sandbox options if you experience lag.
- In multiplayer, the host/server specs matter greatly.

## 🐛 Bug Reports

Found an issue? Please report it in the comments or discussions section with as much detail as possible so I can fix it as soon as possible.

## 🔄 Updates & Support

Updates will always be made according to the **Unstable / IWBUMS** branch of the game.
I'll do my best to keep this mod updated with new Project Zomboid releases, but I can't promise updates for every single build right away. I'll work on compatibility as time allows.

## 🙏 Credits

- **Texture Packs:** [Manik_Goblyn](https://steamcommunity.com/id/Manik_Goblyn) — Manik's a Decade Later textures.

*If any texture pack author wishes to have their work removed from this mod, it will be taken down immediately upon request.*

## 🌐 Supported Languages

- English (EN)
- Español / Spanish (ES)
- Deutsch / German (DE)
- Português Brasileiro / Brazilian Portuguese (PT-BR) [Revive: Okijiu](https://steamcommunity.com/profiles/76561198795044894/)

**⚠️ LOAD ORDER PRIORITY:** This mod should be placed as close to the **TOP** of your load order as possible (use the Auto-Sort feature or manually move it up). If other mods overwrite the same world tiles, the load order determines which one takes priority.

*Example load order (Mod IDs):*
```
Mods=errorMagnifier;WorldDecay;ModExample1;ModExample2;
```

*In the in-game mod manager:*
```
1. Error Magnifier
2. WorldDecay
3. Your map mods
4. Other gameplay mods
```

## 📋 Mod Information

- **Workshop ID:** 3725803503
- **Mod ID:** WorldDecay
- **Game Version:** Build 42.17 +
- **Save-Safe:** Yes — Can be added or removed mid-save.
