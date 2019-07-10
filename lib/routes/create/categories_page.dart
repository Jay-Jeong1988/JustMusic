import 'package:flutter/material.dart';

class CategoriesPage extends StatefulWidget {
  List<String> allCategoryTitles;
  List<String> selectedCategoryTitles;
  CategoriesPage(this.allCategoryTitles, this.selectedCategoryTitles);

  State<CategoriesPage> createState() => CategoriesPageState();
}

class CategoriesPageState extends State<CategoriesPage> {
  List<String> _selectedCategoryTitles = [];

  void initState(){
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
                  trailing: _selectedCategoryTitles.contains(widget.allCategoryTitles[index]) ?
                  Icon(Icons.music_note, color: Colors.white) : Text(""),
                  onTap: (){
                    setState((){
                      _selectedCategoryTitles.contains(widget.allCategoryTitles[index]) ?
                        _selectedCategoryTitles.remove(widget.allCategoryTitles[index])
                      : _selectedCategoryTitles.add(widget.allCategoryTitles[index]);
                      print("${widget.allCategoryTitles[index]} is selected");
                    });
                  }
              );
            })
      ));
  }
}