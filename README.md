# Vanilla OS Meta Appstream

This repository contains app stream metainfo files and tools for adding new packages to Vanilla OS Meta.

## How it works

Every application part of Vanilla OS Meta needs to have a `.metainfo.xml` file, which is then used by
the builder script to create an Appstream Catalog file (the file shipped by our repository).
A [metainfo](https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#sect-Metadata-GenericComponent) file is, at its core, an XML file that describes all aspects of an application and is used by
software stores such as GNOME Software or KDE's Discover to provide information to the user.
Inside a metainfo file, we provide information about a component which can be a desktop application, a library, a font, or a codec, such as its id, name, description, license, categories, etc.
An Appstream Catalog is a collection of components that can get installed on the system.

## Contributing

### How to add a new application

We provide a template metainfo file inside `utils/` that contains all tags required for adding a
basic application. But a good metainfo file contains much more information than just the
mandatory tags. Some elements you should consider adding are:
- Extra [url's](https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#tag-url) for the projects bug tracker, donations page, repository, etc
- Older [releases](https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#tag-releases) with detailed changelogs
- MIME types inside [provides](https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#tag-provides) if the application handles specific file types
- [Screenshots](https://www.freedesktop.org/software/appstream/docs/chap-Metadata.html#tag-screenshots) of the application
- Localized tags for name, description, and summary

The metainfo file should be named `the.application.id.metainfo.xml` and placed inside
`/packages/usr/share/metainfo`.

### Where to find information about an application

Most of the time, if the application you wish to add already has a version on Flathub, we would
advise against submitting it to Vanilla OS Meta and using the Flathub version instead.
However, some applications like Steam may have some quirks in their Flatpak versions that could
justify a place in the Apx repository.
Most Flathub applications contain a metainfo file in their [Flathub repository](https://github.com/flathub/)
(or a `.appdata.xml`, which got deprecated in favour of metainfo) that you could use as a reference
for populating your file.

If the application doesn't have a version on Flathub, you should try searching the app's repository
for relevant information. You can often find short descriptions in the README and the required screenshots inside the hosted repository.

### How to build the Catalog

Before submitting a new application, you must ensure your contribution contains valid Appstream
elements, as it will not appear in the software stores if malformed.
We provide a builder script inside `/utils` that will generate an Appstream Catalog with all
metainfo files and report any issues it finds for each application.
You should make sure the script at least doesn't report any errors, but you should also handle any
warnings and suggestions if they apply.

To run the builder script, you need the following packages:
- *appstream*
- *appstream-compose*

**NOTE:** At the time of writing, the most recent `appstreamcli` version in the default (apt)
Apx container is *0.15.2*, which contains a bug that causes metainfo validation to return an error
for all release timestamps.
This bug got fixed in version *0.15.6*, which is available in the OpenSUSE repositories, so we
strongly recommend running the build script inside Apx Zypper container.

```sh
$ apx --zypper enter
$ sudo zypper install AppStream AppStream-compose gzip
$ ./util/appstream_builder.sh
```
