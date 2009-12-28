package {

import com.bit101.components.HSlider;
import com.flashartofwar.BitmapDataCollectionSampler;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.net.URLRequest;

public class BitmapDataCollectionSamplerApp extends Sprite {

    protected var preloadList:Array = ["image1.jpg","image2.jpg","image4.jpg","image2.jpg","image2.jpg","image3.jpg","image4.jpg","image5.jpg","image1.jpg","image2.jpg","image4.jpg","image2.jpg"];
    protected static const BASE_URL:String = "images/";
    protected var currentlyLoading:String;
    protected var loader:Loader = new Loader();
    private var gridPreview:BitmapDataCollectionSampler;
    private var scrubber:HSlider;
    private var layers:Array = [];
    protected var previewScale:Number = .25;
    private var previewDisplay:Bitmap;
    protected var sampleArea:Rectangle = new Rectangle(0, 0, 960, 600);

    public function BitmapDataCollectionSamplerApp()
    {
        configureStage();
        preload();
    }

    private function configureStage():void {
        this.stage.align = StageAlign.TOP_LEFT;
        this.stage.scaleMode = StageScaleMode.NO_SCALE;
    }

    protected function init():void
    {
        createGridSampler();
        createScrubber();
        addKeyboardListeners();
    }

    private function addKeyboardListeners():void {
        addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown)
    }

    private function onKeyDown(event:KeyboardEvent):void {
        switch (event.keyCode) {
            case 39:
                scrubber.value += 1;
                break;
            case 37:
                scrubber.value -= 1;
                break;
        }
        updateDisplayFromScrubber();
    }

    private function createScrubber():void {
        scrubber = new HSlider(this, 0, 0, onSliderValueUpdate);
        scrubber.width = 960;
        scrubber.y = 10;
    }

    protected function updateDisplayFromScrubber():void {
        var percent:Number = scrubber.value / 100;
        var s:Number = gridPreview.totalWidth;
        var t:Number = sampleArea.width;

        sampleArea.x = percent * (s - t);

        previewDisplay.bitmapData = gridPreview.sampleBitmapData(sampleArea);
    }

    private function onSliderValueUpdate(event:Event):void {
        updateDisplayFromScrubber();
    }


    private function createGridSampler():void {

        gridPreview = new BitmapDataCollectionSampler(layers);

        previewDisplay = new Bitmap();

        addChild(previewDisplay);

    }

    /**
     * Handles preloading our images. Checks to see how many are left then
     * calls loadNext or compositeImage.
     */
    protected function preload():void
    {
        if (preloadList.length == 0)
        {
            init();
        }
        else
        {
            loadNext();
        }
    }

    /**
     * Loads the next item in the prelaodList
     */
    private function loadNext():void
    {
        currentlyLoading = preloadList.shift();
        loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad);

        loader.load(new URLRequest(BASE_URL + currentlyLoading));
    }

    /**
     * Handles onLoad, saves the BitmapData then calls preload
     */
    private function onLoad(event:Event):void
    {
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoad);

        layers.push(Bitmap(event.target.content).bitmapData);

        currentlyLoading = null;

        preload();
    }

}
}