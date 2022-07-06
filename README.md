# NFT Holic

A description of this package.

# Writing configuration

In most case, you will want to configure some details about generating images.

Yes, you can put your configuration file as `config.yml` at the root of your input directory.



## Print serial number on your NFT

Print token ID on your NFT with specified text color, font, format, size and position.

```yaml
drawSerial:
  enabled: true
  color: "000000"
  font: M+ 1p black
  format: "#%05d"
  offsetX: 40
  offsetY: 14.5
  size: 38
```



## Adjust probabilities of layered parts

Appearance rate of parts in layers. Default weight is 1. If the target is matched 2 or more name regex, the weight values will be multiplied.

```yaml
randomization:
  probabilities:
  - target:
      layer: 02_body
      name: "^body_((dark)?ape|nihonzaru)_\\d{2}$"
    weight: 1
    divideByMatches: true
  - target:
      layer: 02_body
      name: "^body_bear_\\d{2}$"
    weight: 0.3
    divideByMatches: true
```



## Strict layer combinations

```yaml
combinations:
# use hand and ear same color as body
- target:
    layer: 02_body
    name: "^.*01$"
  dependencies:
  - layer: 03_hand
    name: "^.*01$"
  - layer: 09_ear
    name: "^.*01$"
- target:
    layer: 02_body
    name: "^.*02$"
  dependencies:
  - layer: 03_hand
    name: "^.*02$"
  - layer: 09_ear
    name: "^.*02$"
- target:
    layer: 02_body
    name: "^(?=.*_giraffe_).*$"
  dependencies:
  - layer: 01_backear
    name:
  - layer: 10_clothes
    name: "clothes_[^I]_\\d{2}"
  - layer: 05_hair
    name:
  - layer: 06_eye
    name:
  - layer: 07_faceitem
    name:
  - layer: 08_headitem
    name:
  - layer: 09_ear
    name:
```



## Override orders

```yaml
order:
  layerDepth:
  - 00_BG
  - 01_backear
  - 02_body
  - 03_hand
  - 04_item
  - 05_hair
  - 07_faceitem
  - 08_headitem
  - 06_eye
  - 10_clothes
  - 09_ear
  selection:
  - 00_BG
  - 02_body
  - 03_hand
  - 04_item
  - 10_clothes
  - 05_hair
  - 07_faceitem
  - 08_headitem
  - 06_eye
  - 09_ear
  - 01_backear
```



## Metadata Generation

```yaml
metadata:
  backgroundColor: f7cc1b
  defaultDescriptionFormat: "First collections of ANIM.JP. Serial number is %05d."
  defaultNameFormat: ANIM.JP#%05d
  externalUrlFormat: https://anim.jp
  baseUrl: https://mynft.com
  traitOrder:
  - Family
  - Color
  - Hair
  - Hair Color
  - Eyes
  - Clothing
  traits:
    textLabels:
    # Ape
    - conditions:
      - layer: 02_body
        name: "^(?=.*_((dark)?ape|nihonzaru)_).*$"
      trait: Family
      value: Ape
    # Bear
    - conditions:
      - layer: 02_body
        name: "^(?=.*_bear_).*$"
      trait: Family
      value: Bear
    rarityPercentages:
    - conditions:
      - layer: 07_faceitem
        name: "^"
      trait: Face Gear Rarity
    - conditions:
      - layer: 08_headitem
        name: "^"
      trait: Head Gear Rarity
```

