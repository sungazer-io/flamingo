import 'package:flamingo/flamingo.dart';
import 'package:flamingo_example/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_slidable/flutter_slidable.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CollectionPagingListenerStreamBuilderPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<CollectionPagingListenerStreamBuilderPage> {
  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController = RefreshController();

  late CollectionPagingListener<User> collectionPagingListener;

  @override
  void dispose() async {
    super.dispose();
    await collectionPagingListener.dispose();
  }

  @override
  void initState() {
    super.initState();

    collectionPagingListener = CollectionPagingListener<User>(
      query: User().collectionRef.orderBy('updatedAt', descending: true),
      initialLimit: 20,
      pagingLimit: 20,
      decode: (snap) => User(snapshot: snap),
    )..fetch();

    collectionPagingListener.docChanges.listen((event) {
      for (var item in event) {
        final change = item.docChange;
        print(
            'id: ${item.doc.id}, changeType: ${change.type}, oldIndex: ${change.oldIndex}, newIndex: ${change.newIndex} cache: ${change.doc.metadata.isFromCache}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Collection Paging Listener Sample'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 24, right: 24),
              child: StreamBuilder<List<User>>(
                stream: collectionPagingListener.data,
                initialData: const [],
                builder: (context, snap) {
                  return Text('count: ${snap.data?.length}');
                },
              ),
            )
          ],
        ),
        body: StreamBuilder<List<User>>(
          stream: collectionPagingListener.data,
          initialData: const [],
          builder: (context, snap) {
            final items = snap.data;
            return SmartRefresher(
              controller: refreshController,
              enablePullDown: true,
              enablePullUp: true,
              header: CustomHeader(
                builder: (context, mode) {
                  if (mode == RefreshStatus.idle) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox(
                    height: 55,
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                },
              ),
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.idle) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox(
                    height: 55,
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                },
              ),
              onRefresh: () {
                refreshController.refreshCompleted();
              },
              onLoading: () {
                collectionPagingListener.loadMore();
                refreshController.loadComplete();
              },
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  final data = items![index];
                  return Slidable(
                    actionPane: const SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: ListTile(
                      title: Text(
                        data.id,
                        maxLines: 1,
                      ),
                      subtitle: Text(
                        '${index + 1} ${data.name} ${data.updatedAt?.toDate()}',
                        maxLines: 1,
                      ),
                      onTap: () async {
                        data.name = Helper.randomString();
                        final documentAccessor = DocumentAccessor();
                        await documentAccessor.update(data);
                      },
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () async {
                          final documentAccessor = DocumentAccessor();
                          await documentAccessor.delete(data);
                        },
                      ),
                    ],
                  );
                },
                itemCount: items?.length,
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final item = User()..name = Helper.randomString(length: 5);
            final documentAccessor = DocumentAccessor();
            await documentAccessor.save(item);
          },
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
