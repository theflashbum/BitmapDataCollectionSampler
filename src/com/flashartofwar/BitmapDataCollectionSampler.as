package com.flashartofwar {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BitmapDataCollectionSampler extends Sprite {

    protected var bitmapDataCollection:Array;
    protected var collectionRects:Vector.<Rectangle>;
    protected var _totalWidth:int = 0;
    protected var _maxHeight:Number = 0;
    protected var collectionTotal:int = 0;
    private var bitmapData:BitmapData;
    protected var copyPixelOffset:Point = new Point();

    private var internalSampleArea:Rectangle;

    /**
     * This is used to debug the ExplorerCanvas. It is important to
     * remember that all the bitmapData in the collection Array must
     * be the same size. The sampleScale is a percentage of the first
     * item's width.
     *
     * @param collection
     */
    public function BitmapDataCollectionSampler(collection:Array) {
        bitmapDataCollection = collection.slice();
        init();
    }

    public function get totalWidth():int {
        return _totalWidth;
    }

    public function get maxHeight():Number {
        return _maxHeight;
    }

    protected function init():void {

        indexCollection();
    }

    protected function indexCollection():void {


        var bitmap:Bitmap;
        var bmd:BitmapData;
        var lastX:Number = 0;
        var lastY:Number = 0;
        var padding:Number = 2;
        var i:int;
        collectionTotal = bitmapDataCollection.length;
        var rect:Rectangle;

        collectionRects = new Vector.<Rectangle>(collectionTotal);


        var lastWidth:Number = 0;
        _totalWidth = 0;
        _maxHeight = 0;

        for (i = 0; i < collectionTotal; i ++) {
            bmd = bitmapDataCollection[i] as BitmapData;

            // create a rect to represent the BitmapData
            rect = new Rectangle(lastX, 0, bmd.width, bmd.height);
            collectionRects[i] = rect;

            lastX += bmd.width + 1;
            // Save out width information
            lastWidth = bmd.width;

            _totalWidth += lastWidth;

            if (bmd.height > maxHeight) {
                _maxHeight = bmd.height;
            }
        }

    }

    protected function calculateCollectionStartIndex(sampleCoord:Point):int {

        if (sampleCoord.x < 0)
            return -1;

        var i:int;
        var rect:Rectangle;

        for (i = 0; i < collectionTotal; i ++)
        {
            rect = collectionRects[i];

            if (rect.containsPoint(sampleCoord))
            {
                return i;
            }
        }

        return -1;
    }


    public function sampleBitmapData(sampleAreaSrc:Rectangle):BitmapData
    {
        // We clone this so it will not modify the ordinal sampleArea Rectangle that is passed in
        internalSampleArea = sampleAreaSrc.clone();

        //TODO this needs to be optimized?
        bitmapData = new BitmapData(internalSampleArea.width, internalSampleArea.height, false, 0xFF0000);

        sample(internalSampleArea, bitmapData);

        return bitmapData;
    }

    protected function sample(sampleArea:Rectangle, output:BitmapData, offset:Point = null):void {

        var collectionID:int = calculateCollectionStartIndex(new Point(sampleArea.x, 0));

        if (collectionID != -1)
        {
            var sourceRect:Rectangle = collectionRects[collectionID];

            var sourceBitmapData:BitmapData = bitmapDataCollection[collectionID];

            var leftOver:Number = calculateLeftOverValue(sampleArea.x, sampleArea.width, sourceRect);

            var sampleAreaX:Number = sampleArea.x;

            if (!offset)
                offset = copyPixelOffset;

            var point:Point = calculateSamplePosition(sampleArea, sourceRect);

            sampleArea.x = point.x;
            sampleArea.y = 0;

            output.copyPixels(sourceBitmapData, sampleArea, offset);

            if (leftOver > 0)
            {

                var offsetX:Number = output.width - leftOver;

                offset = new Point(output.width - leftOver, 0);//calculateLeftoverOffset(sampleArea, leftOver);
                var leftOverSampleArea:Rectangle = calculateLeftOverSampleArea(sampleArea, leftOver, sourceRect);

                sample(leftOverSampleArea, output, offset);
            }

        }
    }


    protected function calculateLeftOverValue(offset:Number, sampleWidth:Number, sourceRect:Rectangle):Number {

        //var difference:Number = (offset + sampleWidth) - sourceRect.width;
        var difference:Number = (offset + sampleWidth) - (sourceRect.x + sourceRect.width);

        return (difference < 0) ? 0 : difference;
    }


    protected function calculateLeftoverOffset(sampleArea:Rectangle, leftOver:Number):Point {

        return new Point(sampleArea.width - leftOver, 0);
    }

    protected function calculateLeftOverSampleArea(sampleAreaSRC:Rectangle, leftOver:Number, sourceRect:Rectangle):Rectangle {
        var sampleArea:Rectangle = sampleAreaSRC.clone();
        sampleArea.width = leftOver + 1;
        sampleArea.x = sourceRect.x + sourceRect.width + 1;

        return sampleArea;
    }

    protected function calculateSamplePosition(sampleRect:Rectangle, sourceArea:Rectangle):Point {
        var point:Point = new Point();
        point.x = sampleRect.x - sourceArea.x;

        return point;
    }


}
}