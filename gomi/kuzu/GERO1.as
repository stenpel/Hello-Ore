package
{
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	
	public class sampleFFT extends Sprite
	{
		//const
		private const POS:int = 300;
		private const SCALE:int = 10;
		private const PARTICLE_SIZE:int = 3;
		private const COLOR_BASE:int = 0xffffff;
		
		private static var FLAG:Boolean = true;
		
		private var loader:Loader;
		private var sound:Sound;
		private var conductor:SoundChannel;
		private var mixer:SoundMixer;
		
		//actor
		private var befor_pos:int = 0;
		private var particles:Vector.<Sprite>;
		private var specialthanks:TextField;
		
		public function sampleFFT()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			this.blendMode = BlendMode.DARKEN;
			
			loader = new Loader();
			sound = new Sound();
			sound.addEventListener(Event.OPEN, open);
			sound.load(new URLRequest("music3.mp3"));
		}
		
		private function init():void {
			particles = new Vector.<Sprite>();
			
			specialthanks = new TextField();
			specialthanks.autoSize = "left";
			specialthanks.text = "music by ArtisFeeling";
			specialthanks.selectable = false;
			specialthanks.background = true;
			specialthanks.y = stage.stageHeight - specialthanks.height;
			specialthanks.addEventListener(MouseEvent.CLICK, link);
			specialthanks.addEventListener(MouseEvent.ROLL_OVER, over);
			specialthanks.addEventListener(MouseEvent.ROLL_OUT, out);
			addChild(specialthanks);
		}
		
		private function setPan(pan:Number):void {
			//trace("setPan: " + pan.toFixed(2));
			var transform:SoundTransform = this.conductor.soundTransform;
			transform.pan = pan;
			this.conductor.soundTransform = transform;
		}
		
		private function setVolume(volume:Number):void {
			//trace("setVolume: " + volume.toFixed(2));
			var transform:SoundTransform = this.conductor.soundTransform;
			transform.volume = volume;
			this.conductor.soundTransform = transform;
		}
		
		
		//event
		private function loop(e:Event):void {
			var b:ByteArray = new ByteArray();
			var posy:int = stage.stageHeight / 2;
			var posx:int = stage.stageWidth / 2;
			
			FLAG ? SoundMixer.computeSpectrum(b, true) : SoundMixer.computeSpectrum(b);
			
			for(var i:uint = 0; i < particles.length; i++) {
				var p:Sprite = particles[i];
				if(b.position < b.length) {
					var n:Number = b.readFloat();
					p.scaleX = 1 + Math.abs(n) * SCALE;
					p.scaleY = 1 + Math.abs(n) * SCALE;
					p.y = posy + n * POS;
				} else {
					b.position = 0;
					n = b.readFloat();
					p.scaleX = 1 + Math.abs(n) * SCALE;
					p.scaleY = 1 + Math.abs(n) * SCALE;
					p.y = posy + n * POS;
				}
			}
		}
		
		private function link(e:MouseEvent):void {
			navigateToURL(new URLRequest("http://www.myspace.com/xsoutheastx"));
		}
		
		private function over(e:MouseEvent):void {
			specialthanks.backgroundColor = 0xFF3399;
		}
		
		private function out(e:MouseEvent):void {
			specialthanks.backgroundColor = 0xFFFFFF;
		}
		
		private function click(e:MouseEvent):void {
			FLAG = !(FLAG);
		}
		
		private function move(e:MouseEvent):void {
			var halfStage:uint = Math.floor(stage.stageWidth / 2);
			var xPos:uint = e.stageX;
			var yPos:uint = e.stageY;
			var value:Number;
			var pan:Number;
			
			if (xPos > halfStage) {
				value = xPos / halfStage;
				pan = value - 1;
			} else if (xPos < halfStage) {
				value = (xPos - halfStage) / halfStage;
				pan = value;
			} else {
				pan = 0;
			}
			if(pan > 1) pan = 0;
			
			var volume:Number = 1 - (yPos / stage.stageHeight);
			
			setVolume(volume);
			setPan(pan);
		}
		
		private function open(e:Event):void {
			init();
			
			sound.addEventListener(ProgressEvent.PROGRESS, prog);
			sound.addEventListener(Event.COMPLETE, comp);
		}
		
		private function prog(e:ProgressEvent):void {
			var pos:int = stage.stageWidth * ( sound.bytesLoaded / sound.bytesTotal );
			var c:int = COLOR_BASE * Math.random();
			
			var p:Sprite = new Sprite();
			p.blendMode = BlendMode.OVERLAY;
			p.graphics.beginFill(c);
			p.graphics.drawCircle(0, 0, PARTICLE_SIZE);
			p.graphics.endFill();
			particles.push(p);
			addChild(p);
			p.x = befor_pos;
			p.y = stage.stageHeight / 2;
				
			befor_pos = pos
		}
		
		private function comp(e:Event):void {
			sound.removeEventListener(Event.OPEN, open);
			sound.removeEventListener(ProgressEvent.PROGRESS, prog);		
			
			conductor = sound.play();
			conductor.addEventListener(Event.SOUND_COMPLETE, end);
			
			addEventListener(Event.ENTER_FRAME, loop);
			stage.addEventListener(MouseEvent.CLICK, click);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
			stage.addEventListener(Event.DEACTIVATE, get_out_here);
			stage.addEventListener(Event.ACTIVATE, come_on);
			stage.addEventListener(Event.MOUSE_LEAVE, leave);
		}
		
		private function come_on(e:Event):void {
			trace("come_on");
			stage.addEventListener(MouseEvent.MOUSE_MOVE, move);
		}
		
		private function get_out_here(e:Event):void {
			trace("get_out_here");
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, move);
			this.setVolume(.1);
			this.setPan(0);
		}
		
		private function leave(e:Event):void {
			this.setVolume(.1);
			this.setPan(0);
		}
		
		private function end(e:Event):void {
			conductor = sound.play();
			conductor.addEventListener(Event.SOUND_COMPLETE, end);
		}
	}
}