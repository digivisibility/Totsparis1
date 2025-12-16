import 'package:flutter/material.dart';



class ContainerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width*0.4426769,size.height*0.01361593);
    path_0.cubicTo(size.width*0.4783769,size.height*-0.004550119,size.width*0.5223615,size.height*-0.004550119,size.width*0.5580615,size.height*0.01361593);
    path_0.lineTo(size.width*0.9423077,size.height*0.2091390);
    path_0.cubicTo(size.width*0.9780077,size.height*0.2273051,size.width,size.height*0.2608780,size.width,size.height*0.2972102);
    path_0.lineTo(size.width,size.height*0.6882576);
    path_0.cubicTo(size.width,size.height*0.7245898,size.width*0.9780077,size.height*0.7581610,size.width*0.9423077,size.height*0.7763271);
    path_0.lineTo(size.width*0.5580615,size.height*0.9718508);
    path_0.cubicTo(size.width*0.5223615,size.height*0.9900169,size.width*0.4783769,size.height*0.9900169,size.width*0.4426769,size.height*0.9718508);
    path_0.lineTo(size.width*0.05843173,size.height*0.7763271);
    path_0.cubicTo(size.width*0.02273173,size.height*0.7581610,size.width*0.0007394635,size.height*0.7245898,size.width*0.0007394635,size.height*0.6882576);
    path_0.lineTo(size.width*0.0007394635,size.height*0.2972102);
    path_0.cubicTo(size.width*0.0007394635,size.height*0.2608780,size.width*0.02273173,size.height*0.2273051,size.width*0.05843173,size.height*0.2091390);
    path_0.lineTo(size.width*0.4426769,size.height*0.01361593);
    path_0.close();

    Paint paint0Fill = Paint()..style=PaintingStyle.fill;
    paint0Fill.color = const Color(0xff4A12E9).withOpacity(0.15);
    canvas.drawPath(path_0,paint0Fill);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

