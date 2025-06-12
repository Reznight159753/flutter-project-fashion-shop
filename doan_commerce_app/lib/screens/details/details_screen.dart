import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants.dart';
import '../../models/Model_shop.dart';
import 'components/add_to_cart.dart';
import 'components/counter_with_fav_btn.dart';
import 'components/description.dart';
import 'components/product_title_with_image.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/cart.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          const SizedBox(width: kDefaultPaddin / 2),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: size.height,
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: size.height * 0.35),
                    padding: const EdgeInsets.only(
                      top: kDefaultPaddin * 1.5,
                      left: kDefaultPaddin,
                      right: kDefaultPaddin,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Description(
                          product: widget.product,
                          title: widget.product.title,
                          description: widget.product.description,
                          price: widget.product.price,
                          stock: widget.product.stock,
                        ),
                        const SizedBox(height: kDefaultPaddin),
                        CounterWithFavBtn(
                          onQuantityChanged: (quantity) {
                            setState(() {
                              _quantity = quantity;
                            });
                            print('Quantity updated: $_quantity');
                          },
                          productId: widget.product.id, // Truyền productId
                        ),
                        const SizedBox(height: kDefaultPaddin),
                        AddToCart(product: widget.product, quantity: _quantity),
                      ],
                    ),
                  ),
                  ProductTitleWithImage(
                    product: widget.product,
                    title: widget.product.title,
                    imageUrl: widget.product.image,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}