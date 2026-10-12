
<!-- README.md is generated from README.Rmd. Please edit that file -->

# psc (Principles of Scientific Computing)

<!-- badges: start -->
<!-- badges: end -->

Practical guidance on writing, organizing, sharing, and maintaining code
for research projects.
Read it at <https://morrison-lab.github.io/psc/>.

psc is the computing companion to
[psw (Principles of Scientific Writing)](https://github.com/Morrison-Lab/psw).
Its chapters began in the
[UCD-SERG lab manual](https://github.com/UCD-SERG/lab-manual)
and moved here with their git history,
so they can serve projects outside that group.

## Contents

- **Writing code**: coding style, coding practices, data masking, big data
- **Projects**: code repositories, reproducible environments, code publication
- **Collaboration**: Git and GitHub, collaborative software development,
  continuous integration
- **Tools**: Unix, Quarto

Each page renders as a web page, RevealJS slides, a PDF handout,
and a Word document.

## Building locally

The site is built with [Quarto](https://quarto.org/) from the
[qwt](https://github.com/Morrison-Lab/qwt) website template.

```bash
git submodule update --init --recursive
quarto preview   # live preview
quarto render    # full build into _site/
```

## Acknowledgments

These chapters began in the [UCD-SERG lab manual](https://ucd-serg.github.io/lab-manual/),
a fork of the
[Benjamin-Chung Lab Manual](https://jadebc.github.io/lab-manual/index.html).
We thank Jade Benjamin-Chung and the Benjamin-Chung manual's other original contributors,
Kunal Mishra, Stephanie Djajadi, Nolan Pokpongkiat, Anna Nguyen,
Iris Tong, and Gabby Barratt Heitmann,
for writing the manual and sharing it openly.
The site is built from the [qwt](https://github.com/Morrison-Lab/qwt) Quarto website template,
whose structure also comes from the UCD-SERG lab manual.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).
Pull requests get a rendered preview and automated checks
(spelling, links, lint, non-standard characters).

## License

The text of this site, including the code examples on its pages,
is licensed under the
[Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)](https://creativecommons.org/licenses/by-nc/4.0/),
the license that the UCD-SERG lab manual and the Benjamin-Chung Lab Manual
state on their home pages.
Reuse of that text must credit the authors named under Acknowledgments above.

The rest of the repository's code, such as its R package, scripts, and workflows,
is licensed under the MIT License; see [`LICENSE`](LICENSE).
Vendored Quarto extensions in `_extensions/` keep their own licenses.
