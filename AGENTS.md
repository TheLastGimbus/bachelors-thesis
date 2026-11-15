# Engineering thesis: characterization of a MEMS ion thruster

Thesis is written in Polish, in Typst.
- Author: Mateusz Soszyński
- Supervisor: dr inż. Piotr Szyszka
- Title: Charakteryzacja silnika jonowego wykonanego technikami MEMS
- University: Politechnika Wrocławska, W12 WEFiM (Wydział Elektroniki, Fotoniki i Mikrosystemów). Field of studies: Inteligentna Elektronika

## Layout
- `Praca Inżynierska - ... .typ`: main document (uses `template.typ`, `utils.typ`). The `.pdf` next to it is generated.
- `pomiary/`: measurement CSVs from experiments.
- `sccm to f(U_prozniomiez)/filter/`: Python scripts and fits for gauge voltage -> pressure/inflow (see its README).
- `krętacz/`: PlatformIO firmware for the stepper-driven needle valve (has its own `AGENTS.md`).
- `arduino-voltometer/`: PlatformIO Arduino voltmeter.

## Workflow
- Build the thesis: `typst compile "<main>.typ" "<main>.pdf"`.
- `.githooks/pre-commit` recompiles and stages the PDF when `.typ` files are committed (needs `git config core.hooksPath .githooks`).
- Write thesis text in Polish. Don't edit measurement data files.
