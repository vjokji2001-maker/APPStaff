# Bundled fonts

Poppins, Inter, Nunito and Roboto Mono are bundled for reliable offline startup.
All variants were downloaded from Google Fonts' `fonts.gstatic.com` URLs using
the file metadata in the locked `google_fonts` 6.3.3 package. Each TTF was checked
against that package's expected SHA-256 hash. Each family's OFL license is included.

The application disables runtime font downloads. When adding another font family,
bundle its licensed variants first and extend `test/bundled_fonts_test.dart`.
