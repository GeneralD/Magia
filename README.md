# NFT Holic

A description of this package.

# Writing configuration

In most case, you will want to configure some details about generating images.

Yes, you can put your configuration file as `config.json` at the root of your input directory.



## Print serial number on your NFT

```json
{
	"drawSerial": {
		"enabled": true,
		"format": "#%05d",
		"font": "M+ 1p black",
		"size": 38,
		"color": "000000",
		"offsetX": 40,
		"offsetY": 14.5
	}
}
```



## Adjust probabilities of layered parts

```json
{
	"randomization": {
		"probabilities": [
			{
				"target": {
					"layer": "02_body",
					"name": "^body_dark.*_07$"
				},
				"weight": 0.5
			}
		]
	}
}
```



## Strict layer combinations

```json
{
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
				"name": "^(?=.*_((dark)?ape|nihonzaru)_).*$"
			},
			"dependencies": [
				{
					"layer": "09_ear",
					"name": null
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
				"name": "^(?=.*_giraffe_).*$"
			},
			"dependencies": [
				{
					"layer": "05_hair",
					"name": null
				},
				{
					"layer": "06_eye",
					"name": null
				},
				{
					"layer": "07_faceitem",
					"name": null
				},
				{
					"layer": "08_headitem",
					"name": null
				},
				{
					"layer": "09_ear",
					"name": null
				},
				{
					"layer": "01_backear",
					"name": null
				}
			]
		},
		{
			"target": {
				"layer": "02_body",
				"name": "^.*_0[7-8]$"
			},
			"dependencies": [
				{
					"layer": "06_eye",
					"name": "^eye_(white|fireblue|firered|circleWhite)$"
				}
			]
		},
		{
			"target": {
				"layer": "02_body",
				"name": "^(?!.*_0[7-8])+"
			},
			"dependencies": [
				{
					"layer": "06_eye",
					"name": "^eye_(?!(white$|circleWhite$)).*$"
				}
			]
		}
	]
}

```



## Override orders

```json
{
	"order": {
		"selection": [
			"00_BG",
			"02_body",
			"03_hand",
			"04_item",
			"10_clothes",
			"05_hair",
			"06_eye",
			"07_faceitem",
			"08_headitem",
			"09_ear",
			"01_backear"
		],
		"layerDepth": [
			"00_BG",
			"01_backear",
			"02_body",
			"03_hand",
			"04_item",
			"05_hair",
			"07_faceitem",
			"08_headitem",
			"06_eye",
			"09_ear",
			"10_clothes"
		]
	}
}
```



## Metadata Generation

```json
{
	"metadata": {
		"imageUrlFormat": "https://anim.jp/images/%d",
		"externalUrlFormat": "https://anim.jp",
		"backgroundColor": "f7cc1b",
		"defaultNameFormat": "My NFT #%05d",
		"defaultDescriptionFormat": "The serial number is %05d.",
		"traitOrder": [
			"Family",
			"Color",
			"Item",
			"Face Gear",
			"Head Gear",
			"Face Gear Rarity",
			"Head Gear Rarity"
		],
		"traits": {
			"textLabels": [{
					"trait": "Family",
					"value": "Cat",
					"conditions": [{
						"layer": "02_body",
						"name": "^(?=.*_(dark)?cat(pattern)?_).*$"
					}]
				},
				{
					"trait": "Family",
					"value": "Dog",
					"conditions": [{
						"layer": "02_body",
						"name": "^(?=.*_(dark)?dog_).*$"
					}]
				},
				{
					"trait": "Color",
					"value": "Ash",
					"conditions": [{
						"layer": "02_body",
						"name": "^.*01$"
					}]
				},
				{
					"trait": "Color",
					"value": "Mocha",
					"conditions": [{
						"layer": "02_body",
						"name": "^.*02$"
					}]
				},
				{
					"trait": "Face Gear",
					"value": "Kerchief",
					"conditions": [{
						"layer": "07_faceitem",
						"name": "^faceitem_Eyemask.*$"
					}]
				},
				{
					"trait": "Face Gear",
					"value": "Glasses",
					"conditions": [{
						"layer": "07_faceitem",
						"name": "^faceitem_Glasses.*$"
					}]
				}
			],
			"rarityPercentages": [{
				"trait": "Face Gear Rarity",
				"conditions": [{
					"layer": "07_faceitem",
					"name": "^"
				}]
			}]
		}
	}
}
```

