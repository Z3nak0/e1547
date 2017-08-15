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

import 'dart:async' show Future;
import 'dart:convert' show JSON;

import 'package:logging/logging.dart' show Logger;

import 'http.dart';
import 'models.dart';
import 'tag.dart';

class Client {
  final Logger _log = new Logger('E1547Client');

  HttpCustom _http = new HttpCustom();

  // For example, 'e926.net'
  String host;

  Future<List<Post>> posts(Tagset tags, int page) async {
    _log.info('Client.posts(tags="$tags", page="$page")');

    String body = await _http.get(host, '/post/index.json', query: {
      'tags': tags,
      'page': page,
    }).then((response) => response.body);

    List<Post> posts = [];
    for (var rp in JSON.decode(body)) {
      posts.add(new Post.fromRaw(rp));
    }

    return posts;
  }

  Future<List<Comment>> comments(int postId, int page) async {
    _log.info('Client.comments(postId="$postId", page="$page")');

    String body = await _http.get(host, '/comment/index.json', query: {
      'post_id': postId,
      'page': page,
    }).then((response) => response.body);

    List<Comment> comments = [];
    for (var rc in JSON.decode(body)) {
      comments.add(new Comment.fromRaw(rc));
    }

    return comments;
  }
}
