# NFT Holic

A description of this package.

## Writing configuration

In most case, you will want to configure some details about generating images.

Yes, you can put your configuration file as `config.json` at the root of your input directory.

Example:

```json
{
  "order": {
    "selection": [
      "00_BG",
      "02_body",
      "03_hand",
      "04_item",
      "05_hair",
      "06_eye",
      "07_faceitem",
      "08_headitem",
      "09_ear",
      "01_backear",
      "10_clothes"
    ],
    "layerDepth": [
      "00_BG",
      "01_backear",
      "02_body",
      "03_hand",
      "04_item",
      "05_hair",
      "06_eye",
      "07_faceitem",
      "08_headitem",
      "09_ear",
      "10_clothes"
    ]
  },
  "combinations": [
    {
      "target": {
        "layer": "03_hand",
        "name": "^hand_grap_[0-9]{2}$"
      },
      "dependencies": [
        {
          "layer": "04_item",
          "name": "^item_grap_.*$"
        }
      ]
    },
    {
      "target": {
        "layer": "03_hand",
        "name": "^hand_pinch_[0-9]{2}$"
      },
      "dependencies": [
        {
          "layer": "04_item",
          "name": "^item_pinch_.*$"
        }
      ]
    },
    {
      "target": {
        "layer": "03_hand",
        "name": "^(?!.*(pinch|grap)).*$"
      },
      "dependencies": [
        {
          "layer": "04_item",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*Giraffe).*$"
      },
      "dependencies": [
        {
          "layer": "05_hair",
          "name": "none"
        },
        {
          "layer": "06_eye",
          "name": "none"
        },
        {
          "layer": "07_faceitem",
          "name": "none"
        },
        {
          "layer": "08_headitem",
          "name": "none"
        },
        {
          "layer": "09_ear",
          "name": "none"
        },
        {
          "layer": "01_backear",
          "name": "none"
        },
      ]
    }
  ],
  "drawSerial": {
    "enabled": true,
    "format": "#%05d",
    "font": "M+ 1p black",
    "size": 48,
    "color": "#000000",
    "offsetX": 40,
    "offsetY": 10
  }
}
```

