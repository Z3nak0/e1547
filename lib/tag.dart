// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:collection' show IterableMixin;

class Tag {
  Tag(this.name, [this.value]);

  factory Tag.parse(String tag) {
    assert(tag != null, "Can't parse a null tag.");
    assert(tag.trim().isNotEmpty, "Can't parse an empty tag.");
    List<String> components = tag.trim().split(':');
    assert(components.length == 1 || components.length == 2);

    String name = components[0];
    String value = components.length == 2 ? components[1] : null;
    return new Tag(name, value);
  }

  final String name;
  final String value;

  @override
  String toString() => value == null ? name : '$name:$value';

  @override
  bool operator ==(dynamic other) => // ignore: avoid_annotating_with_dynamic
      other is Tag && name == other.name && value == other.value;

  @override
  int get hashCode => toString().hashCode;
}

class Tagset extends Object with IterableMixin<Tag> {
  Tagset(Set<Tag> tags)
      : _tags = new Map.fromIterable(
          tags,
          key: (t) => (t as Tag).name,
          value: (t) => t as Tag,
        );

  Tagset.parse(String tagString) : _tags = {} {
    for (String ts in tagString.split(new RegExp(r'\s+'))) {
      if (ts.trim().isEmpty) {
        continue;
      }
      Tag t = new Tag.parse(ts);
      _tags[t.name] = t;
    }
  }

  final Map<String, Tag> _tags;

  // Get the URL for this search/tagset.
  Uri url(String host) => new Uri(
        scheme: 'https',
        host: host,
        path: '/post',
        queryParameters: {'tags': toString()},
      );

  @override
  bool contains(Object tagName) {
    return _tags.containsKey(tagName);
  }

  String operator [](String name) {
    Tag t = _tags[name];
    if (t == null) {
      return null;
    }

    return t.value;
  }

  void operator []=(String name, String value) {
    _tags[name] = new Tag(name, value);
  }

  void remove(String name) {
    _tags.remove(name);
  }

  @override
  Iterator<Tag> get iterator => _tags.values.iterator;

  // The toString order isn't the same as the iteration order. We order the metatags ahead of the
  // normal tags.
  @override
  String toString() {
    List<Tag> meta = [];
    List<Tag> normal = [];

    for (Tag t in _tags.values) {
      if (t.value != null) {
        meta.add(t);
      } else {
        normal.add(t);
      }
    }

    // This isn't terribly efficient, but it probably doesn't matter since the strings are tiny.
    // Something that could be interesting to use here since it would be lazy:
    //    https://www.dartdocs.org/documentation/quiver/0.25.0/quiver.iterables/concat.html
    //
    //    Iterable<T> concat<T>(
    //      Iterable<Iterable<T>> iterables
    //    )

    meta.addAll(normal);
    return meta.join(' ');
  }
}
