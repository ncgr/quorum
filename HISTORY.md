## 0.3.3 (2012-07-19)

* Fixed discover input sequence type bug. Upper and lowercase
  input sequences are typed correctly.

## 0.3.2 (2012-06-22)

* Added support for user defined callback in QUORUM.pollResults().
  Useful if user chooses to define their own view template(s).
  See app/assets/javascripts/quorum/quorum.js and
  app/views/quorum/jobs/show.html.erb for more information.
* JS bug fixes.
* Added specs and updated gems.

## 0.3.1 (2012-04-02)

* Added quorum layouts to quorum:views generator.

## 0.3.0 (2012-01-31)

* Created QUORUM JS object and added properties.

## 0.2.1 (2012-01-24)

* Rails 3.2 compatible.
* Bug fix.

## 0.2.0 (2012-01-20)

* Added link to Download Sequence in detailed report view.
* Added `rails g quorum:images` to override images.
* Deprecated Quorum initializer method `blast_script`.

## 0.1.0 (2012-01-06)

* Initial release.
