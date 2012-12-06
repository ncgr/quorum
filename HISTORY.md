## 0.8.1 (2012-12-06)

* SSH bug fix.

## 0.8.0 (2012-11-30)

* Major refactoring and bug fixes.
* Merged feature branch data_export. Search results are available as .txt (tab
  delimited), .gff (GFF3) and JSONi (default).
* Shortened search url to /quorum/jobs/:id/search?algo=[ie: blastn]
* Search returns [{ enqueued: false }] if algorithm was not enqueued.
* Upgrading? Install migrations and run generators.

## 0.7.1 (2012-11-07)

* Added quorum:delete_jobs rake task.
* Bug fixes.

## 0.7.0 (2012-10-02)

* Fixed empty blast report bug. https://github.com/ncgr/quorum/issues/6
* Added max_sequence_size to quorum_settings.yml to allow user to specify
  max input sequence size in bytes. Defaults to 50 KB.

## 0.6.0 (2012-09-21)

* Renamed blast report max_score to max_target_seqs to match NCBI Blast
  reports. Updated search interface. NOTE: requires migration install.
* Updated the default search interface:
* Enabled gapped alignments by default.
* Improved existing filter options (NCBI Blast DUST and SEG) to use NCBI Blast
  default values.
* Fixed Rails 3.2 multiple select validation error.
* Refactored travis-ci rake tasks.
* Added default spec runner task.

## 0.5.2 (2012-09-14)

* Removed jQuery ajax timeout for long lasting blast jobs.

## 0.5.1 (2012-09-14)

* Fixed Quorum::VERSION uninitialized constant error when overriding views.

## 0.5.0 (2012-09-14)

* Fixed partial data load bug. https://github.com/ncgr/quorum/issues/2
  Requires running quorum:install and quorum:views generators.
  See the Upgrading? section in the README for more information.
* Added better support for jQuery ajax errors in quorum.js.
* Added better support for URLs in quorum.js.

## 0.4.0 (2012-08-10)

* Added Hsp gaps to Blast Job Reports.
  To add gaps: `rake quorum:install:migrations` `rake db:migrate`
* Upgraded bio-blastxmlparser to v1.1.0.
  See https://github.com/pjotrp/blastxmlparser/pull/1
* Fixed JavaScript RangeError: Max call stack size exceeded bug in views.
  Bug was present in large datasets.
* General refactoring.
* Updated dependencies.

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
