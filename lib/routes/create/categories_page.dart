import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  final List<String> allCategoryTitles;
  final List<String> selectedCategoryTitles;
  CategoriesPage(this.allCategoryTitles, this.selectedCategoryTitles);

  State<CategoriesPage> createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  List<String> _selectedCategoryTitles = [];

  void initState(){
    super.initState();
    if (widget.selectedCategoryTitles != null) {
      _selectedCategoryTitles = widget.selectedCategoryTitles.isNotEmpty ?
      widget.selectedCategoryTitles
          : [];
    }
  }

  Widget _customBackButton(){
    return IconButton(icon: Icon(Icons.arrow_back_ios), color: Colors.white,
    onPressed: ()=>Navigator.pop(context, _selectedCategoryTitles));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(43, 47, 57, 1.0),
      appBar: AppBar(
        leading: _customBackButton(),
        elevation: 50,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
          padding: EdgeInsets.all(5.0),
          child: ListView.separated(
            itemCount: widget.allCategoryTitles.length,
          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white),
    itemBuilder: (BuildContext context, int index) {
           return ListTile(
                  title: Text(widget.allCategoryTitles[index],
                      style: TextStyle(color: Colors.white)),
                  trailing: _selectedCategoryTitles.contains(widget.allCategoryTitles[index].toLowerCase()) ?
                  Icon(Icons.music_note, color: Colors.white) : Text(""),
                  onTap: (){
                    var categoryTitle = widget.allCategoryTitles[index].toLowerCase();
                    setState((){
                      _selectedCategoryTitles.contains(categoryTitle) ?
                        _selectedCategoryTitles.remove(categoryTitle)
                      : _selectedCategoryTitles.add(categoryTitle);
                      print("$categoryTitle is selected");
                    });
                  }
              );
            })
      ));
  }
}