//------------------------------------------------------------------------------
//  Copyright (c) 2011, George, neatfilm.com.   
//  All rights reserved. 
// 
//  Redistribution and use in source and binary forms, with or without  
//  modification, are permitted provided that the following conditions are 
//  met: 
//  * Redistributions of source code must retain the above copyright notice,  
//    this list of conditions and the following disclaimer. 
//  * Redistributions in binary form must reproduce the above copyright 
//    notice, this list of conditions and the following disclaimer in the  
//    documentation and/or other materials provided with the distribution. 
//  * Neither the name of Adobe Systems Incorporated nor the names of its  
//    contributors may be used to endorse or promote products derived from  
//    this software without specific prior written permission. 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
//  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
//  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR  
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
//  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
//------------------------------------------------------------------------------
package com.neatfilm.framework.view
{
	import flash.events.EventDispatcher;
	import com.neatfilm.framework.debug.Debug;
	import com.neatfilm.framework.debug.LogType;

	/**
	 * Simple object event manager, event listeners would be managed by object itself
	 * For generic purpose and better performance, each event type should have a single listener.
	 * @author george
	 *
	 */
	public class ObjectEventManager implements IObjectEventManager
	{
		private var eventMap:Object = {};

		private var _owner:EventDispatcher;

		/**
		 * Event manager owner object
		 * @param value
		 *
		 */
		public function set owner(value:EventDispatcher):void
		{
			_owner = value;
		}

		/**
		 * Register an event, same as addEventListener
		 * @param type
		 * @param listener
		 *
		 */
		public function registerEvent(type:String, listener:Function):void
		{
			if (eventMap.hasOwnProperty(type))
			{
				if (Debug.debug)
					Debug.log('Object ' + _owner + ' listen type may conflict: ' + type, LogType.WARNING);
				_owner.removeEventListener(type, (eventMap[type] as Function));
			}
			eventMap[type] = listener;
			_owner.addEventListener(type, listener);
		}

		/**
		 * unregister an event, same as removeEventListener
		 * @param type
		 *
		 */
		public function unregisterEvent(type:String):void
		{
			if (eventMap.hasOwnProperty(type))
			{
				_owner.removeEventListener(type, (eventMap[type] as Function));
				delete eventMap[type];
			}
		}

		/**
		 * reset events for reuse owner object
		 *
		 */
		public function reset():void
		{
			for (var type:String in eventMap)
			{
				_owner.removeEventListener(type, (eventMap[type] as Function));
				delete eventMap[type];
			}
		}

		/**
		 * destroy event manager, clear all references
		 *
		 */
		public function destroy():void
		{
			reset();
			_owner = null;
		}
	}
}
