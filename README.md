# Shaderize your flutters.

Example:
 - Switch 2 widget with a transition at middle
 - interactive with shader canvas
   
https://github.com/quochuynh67/FlutterResearchShader/assets/38383168/ad24a5bc-eba9-4803-a776-4edcbddcb237

To custom transition check the example here and write/update glsl script: https://www.shadertoy.com/results?query=tag%3Dtransition

## Getting started

Use Flutter 3.7 or later, and follow [this guide](https://docs.flutter.dev/development/ui/advanced/shaders).

## How to use
1. In your code, prepare a `Shady` instance with details about the shader program. It's important to add *all* uniforms and texture samplers, and to add them in *the same order* as they appear in the shader program.

    ```
    /* assets/shaders/my_shader.frag */

    uniform float uniformOne;
    uniform float uniformTwo;
    uniform sampler2D textureOne;

    [...]
    ```

    ```
    /* Flutter code */

    final shady = Shady(
      assetName: 'assets/shaders/my_shader.frag',
      uniforms: [
        UniformFloat(key: 'uniformOne'),
        UniformFloat(key: 'uniformTwo'),
      ],
      samplers: [
        TextureSampler(
          key: 'textureOne',
          asset: 'assets/texture1.png',
        ),
      ],
    );

    [...]
    ```
2. Use one of the supplied widgets where you want to display your shader.
    ```
    SizedBox(
      width: 200,
      height: 200,
      child: ShadyCanvas(shady),
    ),
    ```
3. Modify your shader parameters by using your `Shady` instance at runtime
    ```
    shady.setUniform<double>('uniformOne', 0.4);
    shady.setTexture('textureOne', 'assets/texture2.png');
    shady.setBlendMode(BlendMode.modulate);
    ```

## Other features

#### Transformers

Transformers are callbacks that are called every frame to transform a uniform value using the previous value and a delta time.

```
  UniformFloat(
    key: 'uniformOne',
    transformer: (previousValue, deltaDuration) {
      return previousValue + (deltaDuration.inMilliseconds / 1000);
    },
  )
```

There are some common premade transforms available as static members on the `Uniform*` classes.

```
  // This is equivalent to the above snippet

  UniformFloat(
    key: 'uniformOne',
    transformer: UniformFloat.secondsPassed,
  )
```

Transformers can be switched at any time.

```
  shady.setTransformer<double>(
    'uniformOne',
    (previousValue, deltaDuration) {
      // Let's go twice as fast!
      return previousValue + ((deltaDuration.inMilliseconds / 1000) * 2);
    },
  );
```

#### Using ShaderToy shaders

[ShaderToy](https://www.shadertoy.com/) is an awesome playground for GLSL experimentation. However, both it and Flutter have some quirks and magic in how shaders are written.

To use a ShaderToy shader (with some limitations), wrap it like this:
```
#include <flutter/runtime_effect.glsl>
uniform vec3 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform float iFrameRate;
uniform vec4 iMouse;
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
////////////// Shadertoy BEGIN

[ Paste your Shadertoy shader code here ]

////////////// Shadertoy END
void main(void) { mainImage(fragColor, FlutterFragCoord()); }
```

Then, when creating your `Shady` instance, flag it using the parameter `shaderToy` to automatically add and wire the ShaderToy uniforms. The supported uniforms will then automatically be updated the same way as they are on ShaderToy.

```
Shady(
  assetName: 'assets/shaders/my_shadertoy_shader.frag'),
  shaderToy: true,
)
```

Only the ShaderToy uniforms listed are supported, and the only supported data type for channels is 2D textures (`sampler2D`).


#### Interactive shaders

Shady includes a convenience widget for interactive shaders. It will wire interactions to selected uniforms and give you callbacks for interception.

```
ShadyInteractive(
  shady,

  // This vec2 uniform will hold normalized
  // coordinates of the latest interaction.
  uniformVec2Key: 'inputCoord',

  // A callback that is called on interaction.
  onInteraction: (coord) => print('Was interacted at $coord'),
)
```

A Shady that has been flagged as `shaderToy` will have the `iMouse` uniform automatically wired.

## Additional information

If you are using your shader outside of the supplied widgets, you'll need to call the `.load()` method
on the Shady instance before usage.

The `example` app has a gallery of various shaders. Have a look for inspiration and such.# FlutterResearchEverything
# FlutterResearchEverything
