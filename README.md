# NFT Holic

A description of this package.

## Writing configuration

In most case, you will want to configure some details about generating images.

Yes, you can put your configuration file as `config.json` at the root of your input directory.

Example:

```json
{
  "drawSerial": {
    "enabled": true,
    "format": "#%05d",
    "font": "M+ 1p black",
    "size": 48,
    "color": "#000000",
    "offsetX": 40,
    "offsetY": 10
  },
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
        "layer": "02_body",
        "name": "^.*01$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*01$"
        },
        {
          "layer": "09_ear",
          "name": "^.*01$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*02$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*02$"
        },
        {
          "layer": "09_ear",
          "name": "^.*02$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*03$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*03$"
        },
        {
          "layer": "09_ear",
          "name": "^.*03$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*04$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*04$"
        },
        {
          "layer": "09_ear",
          "name": "^.*04$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*05$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*05$"
        },
        {
          "layer": "09_ear",
          "name": "^.*05$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*06$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*06$"
        },
        {
          "layer": "09_ear",
          "name": "^.*06$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*07$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*07$"
        },
        {
          "layer": "09_ear",
          "name": "^.*07$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*08$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*08$"
        },
        {
          "layer": "09_ear",
          "name": "^.*08$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*09$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*09$"
        },
        {
          "layer": "09_ear",
          "name": "^.*09$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^.*10$"
      },
      "dependencies": [
        {
          "layer": "03_hand",
          "name": "^.*10$"
        },
        {
          "layer": "09_ear",
          "name": "^.*10$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_(dark)?ape_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_bear_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_bear_).*$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_boar_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_boar_).*$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_(dark)?cat(pattern)?_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_cat_).*$"
        },
        {
          "layer": "01_backear",
          "name": "^backear_cat$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_crow_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "none"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_(dark)?dog_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_dog_).*$"
        },
        {
          "layer": "01_backear",
          "name": "^backear_dog$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_darkness_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "none"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_deer_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_deer_).*$"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_lion_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_lion_).*$"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_penguin_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "none"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_platypus_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "none"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_rabbit_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_rabbit_).*$"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_(dark)?rat_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_rat_).*$"
        },
        {
          "layer": "01_backear",
          "name": "^backear_rat$"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_leopard_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_leopard_).*$"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
    {
      "target": {
        "layer": "02_body",
        "name": "^(?=.*_tiger_).*$"
      },
      "dependencies": [
        {
          "layer": "09_ear",
          "name": "^(?=.*_tiger_).*$"
        },
        {
          "layer": "01_backear",
          "name": "none"
        }
      ]
    },
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
        "name": "^(?=.*_giraffe_).*$"
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
        }
      ]
    }
  ],
  "metadata": {
    "imageUrlFormat": "https://anim.jp/images/%d",
    "externalUrlFormat": "https://anim.jp",
    "backgroundColor": "FFFF00",
    "defaultNameFormat": "ANIM.JP#%05d",
    "defaultDescriptionFormat": "First collections of ANIM.JP.\nEvery NFT is identified by serial number. The number of this is %05d.",
    "textLabels": [
      {
        "trait": "Family",
        "value": "Ape",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_(dark)?ape_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Bear",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_bear_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Boar",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_boar_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Cat",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_(dark)?cat(pattern)?_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Crow",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_crow_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Dog",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_(dark)?dog_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Unknown",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_darkness_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Deer",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_deer_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Giraffe",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_giraffe_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Lion",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_lion_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Penguin",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_penguin_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Platypus",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_platypus_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Rabbit",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_rabbit_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Rat",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_(dark)?rat_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Leopard",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_leopard_).*$"
          }
        ]
      },
      {
        "trait": "Family",
        "value": "Tiger",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^(?=.*_tiger_).*$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Ash",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*01$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Mocha",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*02$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Snow",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*03$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Onyx",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*04$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Mustard",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*05$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Crimson",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*06$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Shadow",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*07$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Cosmic",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*08$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Chocolate",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*09$"
          }
        ]
      },
      {
        "trait": "Color",
        "value": "Desert",
        "conditions": [
          {
            "layer": "02_body",
            "name": "^.*10$"
          }
        ]
      }
    ]
  }
}
```

