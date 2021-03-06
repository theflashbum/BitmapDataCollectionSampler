package com.flashartofwar
{
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.flexunit.Assert;

/**
 * @author jessefreeman
 */
public class BitmapDataCollectionSamplerTest extends BitmapDataCollectionSampler
{

    public function BitmapDataCollectionSamplerTest()
    {
        var collection:Vector.<BitmapData> = new Vector.<BitmapData>();

        for (var i:int; i < 3; i ++)
        {
            // Create dummy images
            collection.push(new BitmapData(demoImageWidth, demoImageHeight, false, 0x000000));
        }

        super(collection);


    }

    private const demoImageHeight:int = 680;

    private var demoImageWidth:int = 1023;

    [Test]
    public function testTotalWidth():void
    {
        Assert.assertEquals(totalWidth, demoImageWidth * 3);
    }

    [Test]
    public function testMaxHeight():void
    {
        Assert.assertEquals(maxHeight, demoImageHeight);
    }

    [Test]
    public function test1stCollectionRect():void
    {
        var rect:Rectangle = collectionRects[0];
        Assert.assertEquals(rect.toString(), "(x=0, y=0, w=" + demoImageWidth + ", h=" + demoImageHeight + ")");

    }

    [Test]
    public function test2ndCollectionRect():void
    {
        var rect:Rectangle = collectionRects[1];
        Assert.assertEquals(rect.toString(), "(x=" + (demoImageWidth + 1) + ", y=0, w=" + demoImageWidth + ", h=" + demoImageHeight + ")");
    }

    [Test]
    public function test3rdCollectionRect():void
    {
        var rect:Rectangle = collectionRects[2];
        Assert.assertEquals(rect.toString(), "(x=" + (demoImageWidth * 2 + 2) + ", y=0, w=" + demoImageWidth + ", h=" + demoImageHeight + ")");
    }

    [Test]
    public function testCalculateLeftoverForInRangeSample():void
    {
        var leftover:Number = calculateLeftOverValue(0, 200, collectionRects[0]);
        Assert.assertEquals(leftover, 0);
    }

    [Test]
    public function testCalculateLeftoverForOutOfRangeSample():void
    {
        var leftover:Number = calculateLeftOverValue(0, demoImageWidth + (demoImageWidth / 2), collectionRects[0]);
        Assert.assertEquals(leftover, demoImageWidth / 2);
    }

    [Test]
    public function testCalculateStartIndex0():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(0, 0)), 0);
    }

    [Test]
    public function testCalculateStartIndex1():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(demoImageWidth + 30, 0)), 1);
    }

    [Test]
    public function testCalculateStartIndex2():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(demoImageWidth * 2 + 30, 0)), 2);
    }

    [Test]
    public function testCalculateStartIndexOutOfRange1():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(-500, 0)), -1);
    }

    [Test]
    public function testCalculateStartIndexOutOfRange2():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(demoImageWidth * (bitmapDataCollection.length + 1), 0)), -1);
    }

    [Test]
    public function testCalculateSamplePosition():void
    {
        var sr:Rectangle = new Rectangle(20, 0, 50, 50);
        var sa:Rectangle = new Rectangle(0, 0, 100, 50);

        var point:Point = calculateSamplePosition(sr, sa);
        Assert.assertEquals(point.toString(), "(x=20, y=0)");
    }

    [Test]
    public function testCalculateSamplePosition2():void
    {
        var sr:Rectangle = new Rectangle(150, 0, 100, 50);
        var sa:Rectangle = new Rectangle(100, 0, 100, 50);

        var point:Point = calculateSamplePosition(sr, sa);
        Assert.assertEquals(point.toString(), "(x=50, y=0)");
    }

    [Test]
    public function testExternalSampleRectIsNotModified():void
    {
        var sampleArea:Rectangle = new Rectangle(0, 0, 500, 100);

        sampleBitmapData(sampleArea);

        Assert.assertEquals(sampleArea.toString(), "(x=0, y=0, w=500, h=100)");
    }

    [Test]
    public function testCalculateCollectionStartIndexOnRectStart():void
    {
        Assert.assertEquals(calculateCollectionStartIndex(new Point(demoImageWidth + 1, 0)), 1);
    }

}
}
