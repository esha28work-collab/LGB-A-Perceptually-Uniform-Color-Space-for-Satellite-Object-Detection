# LGB: A Perceptually Uniform Color Space for Satellite Object Detection

---

## Overview

Most object detection pipelines accept images in the standard **RGB** color space without question. This work challenges that default. We demonstrate that the red channel — the most redundant of the three RGB channels in luminance-heavy satellite scenes — can be replaced with a more informative brightness representation to measurably improve detection performance.

We propose and evaluate **LGB**, a novel input color space derived from the perceptually uniform **OKLab** color model, and compare it against the RGB baseline and the previously published **YGB** space. All three color spaces are evaluated on identical YOLOv8n architectures trained from scratch on the **SIMD** (Satellite Imagery Multi-vehicles Dataset) [gotten from kaggle](https://www.kaggle.com/datasets/akhileshnegi/satellite-imagery-of-multiple-vehicles/data), using a channel masking XAI pipeline to explain *why* a given color space works, not just *how well* it works.

---
<p align="center">
  <img src="figures/pipeline.png" alt="MCSE-YOLO Framework Pipeline" width="800"/>
  <br>
  <em>Fig. 1: The overall MCSE-YOLO framework — color conversion, data split, YOLOv8n training, and channel ablation.</em>
</p>

## The Core Idea

RGB has two structural problems for CNN-based detection:

1. **High inter-channel correlation** — The R, G, and B channels share redundant luminance information (pairwise correlations of 0.78–0.98). The network must implicitly resolve this redundancy rather than attending to discriminative object features.
2. **Perceptual non-uniformity** — Equal Euclidean distances in RGB space do not correspond to equal perceived color differences, producing inconsistent feature representations across varying lighting conditions.

We address both by replacing the red channel — the least informative channel for satellite object detection — with an explicit brightness signal:

| Color Space | Channel 1 | Channel 2 | Channel 3 | Key Property |
|-------------|-----------|-----------|-----------|--------------|
| **RGB** | Red | Green | Blue | Baseline (sensor-native) |
| **YGB** | Luminance Y (YCbCr) | Green | Blue | Explicit linear brightness |
| **LGB** | Lightness L (OKLab) | Green | Blue | Perceptually uniform brightness |

The key insight is that **LGB** provides brightness information that is both explicit *and* perceptually uniform — meaning equal numerical differences in L correspond to equal perceived brightness differences across the full luminance range.

---

## Methods at a Glance

### Color Conversion

**YGB** replaces Red with the YCbCr luminance component:
```
Y = 0.299·R + 0.587·G + 0.114·B
```

**LGB** replaces Red with the OKLab lightness component, computed via a four-stage pipeline:
1. **Gamma linearization** — convert sRGB to linear light (removes gamma encoding)
2. **LMS transform** — map linear RGB to cone-response space via matrix M₁
3. **Cube root compression** — approximate the eye's nonlinear brightness sensitivity
4. **Lightness extraction** — derive L via matrix M₂ weighting of compressed cone responses

### Model

- Architecture: **YOLOv8n** (anchor-free, lightweight)
- Three identical models trained from random initialization — one per color space
- Dataset: **SIMD** — 5,000 satellite images, 15 vehicle/aircraft classes, 35,577 annotated instances
- Split: 80% train / 10% validation / 10% test (stratified)
- Class imbalance handled via inverse-frequency weighted loss

### XAI Evaluation — Channel Masking Ablation

Individual input channels are zeroed out during inference. The drop in detection confidence reveals how much the model relies on each channel. Paired t-tests (p < 0.000001) statistically validate that observed differences are not due to chance.

---

## Key Results

### Detection Performance

| Color Space | Precision | Recall | mAP@50 | mAP@50:95 |
|-------------|-----------|--------|--------|-----------|
| RGB | 0.6875 | 0.7348 | 0.7677 | 0.6236 |
| YGB | **0.8273** | 0.6883 | 0.7773 | 0.6237 |
| **LGB** | 0.7084 | **0.7568** | **0.7784** | **0.6264** |

- **LGB** achieves the highest mAP@50 and recall — best overall detection
- **YGB** achieves the highest precision — fewer false positives, suitable for high-precision applications
- **RGB** performs worst on mAP across both IoU thresholds

### Channel Importance (Ablation — Confidence Drop on Masking)

| Model | Channel Masked | Confidence Drop |
|-------|---------------|-----------------|
| RGB | Red | 8.82% |
| YGB | Y (Luminance) | 69.13% |
| **LGB** | **L (Lightness)** | **97.05%** |

The monotonic increase from 8.82% → 69.13% → 97.05% confirms that as the input representation moves from raw RGB to linear luminance to perceptually uniform lightness, the model increasingly centralizes its detection decisions on that first channel — evidence that explicit, high-quality brightness input becomes the dominant cue.

---

## Contributions

1. **LGB Color Space** — A novel three-channel input representation substituting Red with perceptually uniform OKLab lightness, reducing inter-channel redundancy while providing explicit structural brightness.

2. **Three-Way Controlled Comparison** — Identical YOLOv8n architectures trained on RGB, YGB, and LGB, enabling clean attribution of performance differences to color space alone.

3. **XAI Evaluation Framework** — Channel masking ablation combined with paired t-tests provides statistically validated, quantitative evidence of individual channel contributions to detection — an analysis absent from prior color space comparison studies.


---

## Repository Structure

```
mcse-yolo/
├── data/
│   └── simd/                   # SIMD dataset (not included — see dataset source)
├── convert/
│   ├── rgb_to_ygb.py           # YCbCr luminance substitution
│   └── rgb_to_lgb.py           # OKLab lightness substitution (4-stage pipeline)
├── train/
│   └── train.py                # YOLOv8n training script (all three color spaces)
├── xai/
│   └── channel_ablation.py     # Channel masking + confidence drop measurement
├── eval/
│   └── evaluate.py             # mAP, precision, recall computation
├── figures/
│   └── color_comparison.png    # Visual comparison of RGB / YGB / LGB conversion
└── README.md
```

---

## Dependencies

```bash
pip install ultralytics==8.4.38 torch torchvision numpy opencv-python scipy
```

- Python 3.13+
- PyTorch 2.7+
- Ultralytics YOLOv8

---

---

## References

- Ottosson, B. (2020). *A perceptual color space for image processing.* OKLab.
- Tkalcic, M. & Tasic, J.F. (2003). *Colour spaces: perceptual, historical and applicational background.* IEEE.
- Idris, N. & Mashaly, M. (2024). *Beyond RGB: Channel fusion for improved cross-domain car detection.* ICCA 2024.
- Jocher, G., Qiu, J., & Chaurasia, A. (2023). *Ultralytics YOLO.* https://github.com/ultralytics/ultralytics
- Haroon, M. et al. (2020). *Multi-sized object detection using spaceborne optical imagery.* IEEE JSTARS.
