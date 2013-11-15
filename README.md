# LRGlowingButton

LRGlowingButton is a subclass of UIButton which has custom glow built-in.

## Installation

_**Important note if your project uses ARC**: you must add the `-fno-objc-arc` compiler flag to `LRGlowingButton.m` in Target Settings > Build Phases > Compile Sources._

* Drag the `LRGlowingButton.h`, `LRGlowingButton.m` folder into your project. 
* Add the **QuartzCore** framework to your project.

## Usage

In its simplest form, this is how you create an LRGlowingButton instance:

```objective-c
LRGlowingButton *button = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
button.glowsWhenHighlighted = YES;
button.highlightedGlowColor = [UIColor whiteColor];
[self.view addSubview:button];
```
## Result

&nbsp;&nbsp;&nbsp;&nbsp;
![Example White](https://raw.github.com/lightroomapps/LRGlowingButton/assets/Example1.png)
&nbsp;&nbsp;&nbsp;&nbsp;
![Example Red](https://raw.github.com/lightroomapps/LRGlowingButton/assets/Example2.png)
