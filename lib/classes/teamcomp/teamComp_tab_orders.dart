part of 'teamComp.dart';

extension TabOrders on TeamComp {
  Widget getOrdersWidget(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return ListTile(
                leading: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Player Out: ${sub.idPlayerOut}'),
                    Text('Player In: ${sub.idPlayerIn}'),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sub.minute.toString()),
                    Text('Condition: ${sub.condition}'),
                  ],
                ),
                trailing: isPlayed
                    ? sub.minuteReal != null
                        ? Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${sub.minuteReal}\''),
                          )
                        : Icon(
                            Icons.cancel,
                            color: Colors.red,
                          )
                    : IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {},
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
