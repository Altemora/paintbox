# Interface glossary

This glossary fixes the words the interface uses for its main terms in
English (the source language) and Ukrainian (the reviewed translation).
New texts and new translations should use these words. The Ukrainian
terms follow established usage in Ukrainian graphics software, with
Pinta's Ukrainian translation as one reference.

## Translations

The interface has 25 languages. `app_en.arb` is the template and
`app_uk.arb` is a reviewed translation. The other 23 (be, bg, cs,
da, de, el, es, et, fi, fr, hr, hu, it, kk, lt, lv, nl, pl, pt, ro, sk,
sv, tr) are **machine translations** that still need review by native
speakers; corrections are welcome. To add a language, copy
`app_en.arb` to `app_<code>.arb` without the `@` entries, translate the
values, add the language's own name to `AppLanguages`, and run
`melos run gen:l10n`; `arb_completeness_test.dart` checks that every key,
placeholder and select choice is present.

Style rules for every language:

- Menu items that open a dialog end with "…"; other items do not.
- Tool hints and messages are complete sentences with consistent verb
  forms.
- Key names (Shift, Ctrl, Enter, Esc, F5–F8) stay as they are printed on
  the keyboard.
- The interface is a serious tool: no colloquial words and no calques
  where an established term exists.

## Terms

| English | Ukrainian | Notes |
|---|---|---|
| Image | Зображення | The document; also the Image menu. |
| Canvas | Полотно | The image's area; Canvas Size changes it without scaling. |
| Layer | Шар | |
| Background (layer) | Тло | The bottom layer of a new image. |
| Layer Properties | Властивості шару | |
| Opacity | Непрозорість | Never "прозорість" for this value. |
| Transparency | Прозорість | The gradient's transparency mode. |
| Blend mode | Режим змішування | |
| Flatten | Звести шари | Merges all layers into one. |
| Merge Layer Down | Об'єднати з нижнім шаром | |
| Selection | Виділення | |
| Select All / Deselect | Виділити все / Зняти виділення | |
| Invert Selection | Інвертувати виділення | |
| Selection mode | Режим виділення | Replace, Union, Exclude, Xor, Intersect. |
| Antialiasing | Згладжування | |
| Alpha blending | Альфа-змішування | |
| Tolerance | Допуск | |
| Hardness | Твердість | |
| Primary / secondary color | Основний / додатковий колір | |
| Palette | Палітра | |
| Adjustments | Коригування | The menu. |
| Effects | Ефекти | The menu. |
| Levels, Curves | Рівні, Криві | |
| Hue / Saturation | Відтінок / насиченість | |
| Brightness / Contrast | Яскравість / контраст | |
| Invert Colors | Інверсія кольорів | An Adjustments item; the menus of adjustments and effects use nouns. |
| Edit (menu) | Редагування | |
| Gamma | Гамма | |
| Hue, Saturation, Value (HSV) | Відтінок, Насиченість, Яскравість (В, Н, Я) | |
| Auto-Level | Автоматичні рівні | |
| Gaussian Blur | Розмиття Гаусса | "Розмиття" for every blur. |
| Noise | Шум | Add Noise: "Додавання шуму"; Reduce Noise: "Зменшення шуму". |
| Rendering… | Обчислення… | An effect being computed. |
| Seed / Reseed | Зерно / Нове зерно | The random seed of an effect. |
| History | Історія | The window and its steps. |
| Undo / Redo | Скасувати / Повторити | |
| Tools | Інструменти | The window. |
| Rectangle Select | Прямокутне виділення | |
| Ellipse Select | Еліптичне виділення | |
| Lasso Select | Ласо | |
| Magic Wand | Чарівна паличка | |
| Move Selected Pixels | Переміщення виділених пікселів | |
| Move Selection | Переміщення виділення | |
| Paintbrush | Пензель | |
| Pencil | Олівець | |
| Eraser | Гумка | |
| Paint Bucket | Заливка | |
| Gradient | Градієнт | |
| Color Picker | Піпетка | |
| Clone Stamp | Штамп | |
| Recolor | Перефарбування | |
| Text | Текст | |
| Line / Curve | Лінія / крива | |
| Pan | Рука | The tool that moves the view. |
| Zoom | Масштаб | Zoom In / Zoom Out: "Наблизити" / "Віддалити". |
| Rulers | Лінійки | |
| Pixel Grid | Піксельна сітка | |
| Handle | Ручка | The squares that adjust a shape or a selection. |
| Drag | Протягнути, перетягнути | "Протягніть" draws a new shape; "перетягніть" moves something. |
| Click / right-click | Клацання / праве клацання | |
| Theme | Тема | Dark, Light, System default: "Темна", "Світла", "Як у системі". |
| Accent color | Акцентний колір | |
| Language | Мова | |
| Settings | Налаштування | |
| OK / Cancel | Гаразд / Скасувати | |
