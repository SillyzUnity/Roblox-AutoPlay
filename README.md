GitHub's Markdown does not support Discord-style boldness or text sizing. However, you can use GitHub's supported Markdown syntax for formatting text in a standard way. For **bold** text, use double asterisks `**bold text**`, and for headings, you use hash symbols `#` for different heading sizes.

Here's an updated version with proper GitHub-style Markdown formatting:

---

# **Roblox AutoPlay & AutoClicker**

Welcome to the official **Roblox AutoPlay and AutoClicker Script Hub**. This repository contains two powerful Lua scripts:

* **AutoPlay**: Automates character movement and behaviors.
* **AutoClicker**: Automates mouse clicks.

These scripts are meant for educational or testing use in sandbox environments or single-player simulations.

---

## **Script Links**

* [AutoClicker.lua](https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoClicker.lua)
* [AutoPlay.lua](https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoPlay.lua)

---

## **Individual Script Loaders**

### **AutoClicker Loader**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoClicker.lua"))()
```

### **AutoPlay Loader**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoPlay.lua"))()
```

---

## **Combined Loader Script**

This version loads both AutoClicker and AutoPlay in one line.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoClicker.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/SillyzUnity/Roblox-AutoPlay/refs/heads/main/source/AutoPlay.lua"))()
```

---

## **Disclaimer**

These scripts are **for educational or personal use only**. Do not use them in games where automation is against the terms of service. Use responsibly and ethically.

---

## **How to Use**

1. Copy one of the script loaders above.
2. Paste it into your Roblox script executor.
3. Run the script while in a supported game or test place.

Enjoy automated testing or simulation!

---

This version uses **bold text** properly and headings with `#` for different levels. Let me know if this works or if you need further adjustments!
