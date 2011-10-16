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
	/**
	 * Reusable object pool
	 * 
	 * Usage: 
	 *  - create a pool instance
	 *  - set first IReuable object with .reusableObject
	 *  - obtain object from pool with .getObject() function, object will be reused or clone a new one stored in pool
	 *  - release an object with .releaseObject() function, .releaseAll() to release all objects
	 *  - 
	 *  
	 * @author george
	 * 
	 */	
	public class ReusablePool
	{
		/**
		 * pool objects in array 
		 */		
		public var pool:Array = [];
		/**
		 * count for in use objects 
		 */		
		public var inUseCount:uint;
		/**
		 * count for not in use objects 
		 */		
		private var freeCount:uint;

		/**
		 * set first object 
		 * @param value
		 * 
		 */		
		public function set reusableObject(value:IReusable):void
		{
			pool.push(value);
			freeCount++;
		}
		/**
		 * get largest search range, in case if want to traverse all in use objects.
		 * Although object can be released from any position of the pool, reuse objects always count from start.
		 * For example, 100 objects in the pool, if 50 objects in use, search range may about 60 but wouldn't necessary go through the whole array.  
		 * @return largest search range number
		 * 
		 */
		public function get range():uint
		{
			// find minimum range for in-use objects
			var len:int = pool.length;
			var n:int = 0;
			for (var i:int = 0; i < len; i++)
			{
				if ((pool[i] as IReusable).inUse)
				{
					n++;
					if (n >= inUseCount)
						break;
				}
			}
			i++;
			return (i <= len) ? i : len;
		}
		/**
		 * obtain object from pool 
		 * @return 
		 * 
		 */
		public function getObject():IReusable
		{
			var len:int = pool.length;
			if (freeCount > 0)
			{
				freeCount--;
				inUseCount++;
				for (var i:int = 0; i < len; i++)
				{
					// find first no-in-use object
					var object:IReusable = pool[i];
					if (!object.inUse)
					{
						object.inUse = true;
						return object;
					}
				}
			} else
			{
				var newObject:IReusable = (pool[0] as IReusable).cloneNewObject();
				pool.push(newObject);
				newObject.inUse = true;
				inUseCount++;
				return newObject;
			}
			// this should never happen
			return null;
		}
		/**
		 * release object back to pool 
		 * @param object
		 * 
		 */
		public function releaseObject(object:IReusable):void
		{
			inUseCount--;
			freeCount++;
			object.inUse = false;
			object.reset();
		}
		/**
		 * release all objects 
		 * 
		 */
		public function releaseAll():void
		{
			var len:int = range;
			for (var i:int = 0; i < len; i++)
			{
				var object:IReusable = pool[i];
				if (object.inUse)
				{
					releaseObject(object);
				}
			}

		}
		/**
		 * destroy objects for GC 
		 * 
		 */		
		public function destroy():void
		{
			for (var i:int = 0; i < pool.length; i++) 
			{
				(pool[i] as IReusable).destroy();
			}
			pool.splice(0);
		}
	}
}
