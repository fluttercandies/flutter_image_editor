package com.fluttercandies.image_editor.core

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Path
import android.graphics.RectF
import com.fluttercandies.image_editor.option.draw.*

/**
 * Create a new bitmap with the same config as the original bitmap
 * If the original bitmap has no config, use ARGB_8888
 */
fun Bitmap.createNewBitmap(width: Int, height: Int): Bitmap {
    val config = this.config
    return if (config != null) Bitmap.createBitmap(width, height, config) else Bitmap.createBitmap(
        width,
        height,
        Bitmap.Config.ARGB_8888
    )
}

fun Bitmap.draw(option: DrawOption): Bitmap {
    val newBitmap = createNewBitmap(this.width, this.height)
    val canvas = Canvas(newBitmap)
    canvas.drawBitmap(this, 0F, 0F, null)

    for (drawPart in option.drawPart) {
        when (drawPart) {
            is LineDrawPart -> drawLine(canvas, drawPart)
            is RectDrawPart -> drawRect(canvas, drawPart)
            is OvalDrawPart -> drawOval(canvas, drawPart)
            is PointsDrawPart -> drawPoints(canvas, drawPart)
            is PathDrawPart -> drawPath(canvas, drawPart)
        }
    }

    return newBitmap
}

fun drawPath(canvas: Canvas, drawPart: PathDrawPart) {
    val path = Path()
    val close = drawPart.autoClose
    for (p in drawPart.paths) {
        when (p) {
            is MovePathPart -> {
                path.moveTo(p.offset.x.toFloat(), p.offset.y.toFloat())
            }

            is LineToPathPart -> {
                path.lineTo(p.offset.x.toFloat(), p.offset.y.toFloat())
            }

            is ArcToPathPart -> {
                val rectF = RectF(p.rect)
                path.arcTo(rectF, p.start.toFloat(), p.sweep.toFloat(), p.useCenter)
            }

            is BezierPathPart -> {
                if (p.kind == 2) {
                    path.quadTo(
                        p.control1.x.toFloat(),
                        p.control1.y.toFloat(),
                        p.target.x.toFloat(),
                        p.target.y.toFloat()
                    )
                } else if (p.kind == 3) {
                    path.cubicTo(
                        p.control1.x.toFloat(),
                        p.control1.y.toFloat(),
                        p.control2!!.x.toFloat(),
                        p.control2.y.toFloat(),
                        p.target.x.toFloat(),
                        p.target.y.toFloat()
                    )
                }
            }
        }
    }

    if (close) {
        path.close()
    }

    canvas.drawPath(path, drawPart.getPaint())
}

fun drawPoints(canvas: Canvas, drawPart: PointsDrawPart) {
    val points = drawPart.offsets
    val paint = drawPart.getPaint()
    for (point in points) {
        canvas.drawPoint(point.x.toFloat(), point.y.toFloat(), paint)
    }
}

fun drawOval(canvas: Canvas, drawPart: OvalDrawPart) {
    val rect = RectF(drawPart.rect)
    canvas.drawOval(rect, drawPart.getPaint())
}

fun drawRect(canvas: Canvas, drawPart: RectDrawPart) {
    canvas.drawRect(drawPart.rect, drawPart.getPaint())
}

private fun drawLine(canvas: Canvas, drawPart: LineDrawPart) {
    val paint = drawPart.getPaint()
    canvas.drawLine(
        drawPart.start.x.toFloat(),
        drawPart.start.y.toFloat(),
        drawPart.end.x.toFloat(),
        drawPart.end.y.toFloat(),
        paint
    )
}
