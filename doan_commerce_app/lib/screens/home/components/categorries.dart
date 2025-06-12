import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:doan_commerce_app/models/Model_shop.dart'; // Import model
import '../../../constants.dart';

class Categories extends StatefulWidget {
  final List<Category> categories;
  final Function(int) onCategorySelected;

  const Categories({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int selectedIndex = 0;

  final List<String> icons = [
    'assets/icons/all.svg',
    'assets/icons/tshirt.svg',
    'assets/icons/ao-polo.svg',
    'assets/icons/so-mi.svg',
    'assets/icons/ao-the-thao.svg',
    'assets/icons/tank-top.svg',
    'assets/icons/jacket.svg',
    'assets/icons/Bag.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPaddin),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length,
          itemBuilder: (context, index) => buildCategory(index),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        widget.onCategorySelected(widget.categories[index].maDanhMuc);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPaddin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              icons[index % icons.length],
              height: 40,
              color: selectedIndex == index ? kTextColor : kTextLightColor,
            ),
            const SizedBox(height: 5),
            Text(
              widget.categories[index].tenDanhMuc,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedIndex == index ? kTextColor : kTextLightColor,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: kDefaultPaddin / 8),
              height: 2,
              width: 30,
              color: selectedIndex == index ? Colors.black : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
