/**
 * Copyright 2010 The original author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.collections.utils {

	import org.as3commons.collections.LinkedMap;
	import org.as3commons.collections.Map;
	import org.as3commons.collections.SortedMap;
	import org.as3commons.collections.framework.IBasicMapIterator;
	import org.as3commons.collections.framework.IComparator;
	import org.as3commons.collections.framework.IMap;
	import org.as3commons.collections.framework.IMapIterator;
	import org.as3commons.collections.iterators.MapFilterIterator;

	/**
	 * <p>A set of common utilities for working with IMap implementations.</p>
	 * 
	 * @author John Reeves 14.04.2011
	 */
	public class Maps {
		/**
		 * <p>Attempts to retrieve the item mapped to the supplied key.  If the supplied key is not mapped an 
		 * ArgumentError will be thrown.</p>
		 *
		 * @param map the IMap instance to operate on. 
		 * @param key the key to perform the lookup using.
		 * @param errorMessage optional error message which will be used if an Error needs to be thrown.
		 * @return the item mapped to the supplied key.
		 * @throws ArgumentError if no mapping exists for the supplied key.
		 */
		public static function itemOrError(map : IMap, key : *, errorMessage : String = null) : * {
			if (!map.hasKey(key)) {
				throw new ArgumentError(errorMessage || key + " does not exist in supplied map");
			}
			return map.itemFor(key);
		}

		/**
		 * <p>Attempts to retrieve the item mapped to the supplied key.  If the supplied key is not mapped then the
		 * supplied default value will be returned instead.</p>
		 * 
		 * @param map the IMap instance to operate on.
		 * @param key the key to perform the lookup using.
		 * @param defaultValue the value to return if the supplied key does not exist in the supplied Map.
		 * @return if the supplied key exists in the map then the value mapped to that key will be  returned, otherwise 
		 * the supplied defaultValue will be returned instead. 
		 */
		public static function itemOrValue(map : IMap, key : *, defaultValue : *) : * {
			if (!map.hasKey(key)) {
				return defaultValue;
			}
			return map.itemFor(key);
		}

		/**
		 * <p>Attempts to retrieve the item mapped to the supplied key.  If the supplied key is not mapped then the
		 * supplied value will mapped to the key and returned.</p>
		 * 
		 * @param map the IMap instance to operate on.
		 * @param key the key to perform the lookup using.
		 * @param item	if no mapping exists for the supplied key a new mapping will be added between the key and 
		 * this value.
		 * @return if a prior mapping exists for the supplied key then the assosiated value in the map will be 
		 * returned; if no prior mapping exists the supplied value will be returned instead. 
		 */
		public static function itemOrAdd(map : IMap, key : *, item : *) : * {
			if (!map.hasKey(key)) {
				map.add(key, item);
			}
			return item;
		}

		/**
		 * <p>Filters the supplied IMap instance returning a new IMap of the same type which only contains  
		 * mappings where the key meets the supplied predicate.<p>
		 * 
		 * @param map the IMap instance to operate on.
		 * @param predicate	Function which will be be applied to each key in the supplied map.  This function should expect 
		 * a single argument (the key) and return a Boolean value, true if the key should exist in the returned Map instance
		 * or false if it should not be included in the returned Map.
		 * @return a new Map instance consisting only of mappings where the key met the supplied predicate.
		 */
		public static function filterKeys(map : IMap, predicate : Function) : IMap {
			const result : IMap = new ((map as Object).constructor) as IMap;
			for each (var key : * in map.keysToArray()) {
				if (predicate(key)) {
					result.add(key, map.itemFor(key));
				}
			}
			return result;
		}

		/**
		 * <p>Clones the supplied IMap instance returning a new IMap of the same type. If filters are specified,
		 * the resulting map only contains mappings that meet the supplied predicates.<p>
		 * 
		 * <p>The key filter function accepts the current key and returns a boolean
		 * value (<code>true</code> if the key is accepted).</p>
		 * 
		 * <listing>
			function keyFilter(key : *) : Boolean {
			var accept : Boolean = false;
			// test the key
			return accept;
			}
					
			var iterator : IIterator = new MapFilterIterator(map, keyFilter);
		 * </listing>
		 * 
		 * <p>The item filter function accepts the current item and returns a boolean
		 * value (<code>true</code> if the item is accepted).</p>
		 * 
		 * <listing>
			function itemFilter(item : *) : Boolean {
			var accept : Boolean = false;
			// test the item
			return accept;
			}
					
			var iterator : IIterator = new MapFilterIterator(map, keyFilter, itemFilter);
		 * </listing>
		 * 
		 * @param map the IMap instance to operate on.
		 * @param keyFilter Function which will be be applied to each key in the source map.
		 * @param itemFilter Function which will be be applied to each item in the source map.
		 * @return A new IMap instance.
		 */
		public static function clone(source : IMap, keyFilter : Function = null, itemFilter : Function = null) : IMap {
			var result : IMap = new ((source as Object).constructor) as IMap;
			var iterator : IBasicMapIterator = new MapFilterIterator(source, keyFilter, itemFilter);
			var item : *;
			while (iterator.hasNext()) {
				item = iterator.next();
				result.add(iterator.key, item);
			}
			return result;
		}

		/**
		 * <p>Copies all the mappings from the source IMap instance into the supplied destination IMap instance.</p>
		 * 
		 * @example Copies all the entries contained in the source Map into a new Map instance.
		 * &lt;listing version="3.0"&gt;
		 * 		const result : IMap = Maps.copy(source, new Map());
		 * &lt;/listing&gt;
		 * 
		 * @param source IMap instance which contains the entries you wish to copy.
		 * @param destination IMap instance into which all the mappings from the supplied source map will be added.
		 * @return reference to the supplied destination IMap.
		 */
		public static function copy(source : IMap, destination : IMap) : IMap {
			var iterator : IMapIterator = source.iterator() as IMapIterator;
			while (iterator.hasNext()) {
				var item : * = iterator.next();
				destination.add(iterator.key, item);
			}
			return destination;
		}

		/**
		 * Creates, populates and returns a new <code>Map</code> instance.
		 * 
		 * <p>The arguments may be left out. In that case no item is added to the map.</p>
		 * 
		 * <p>The last argument is skipped if the size of arguments is not even.</p>
		 * 
		 * <listing>
				var map : Map = Maps.map(key1, item1, key2, item2, ...);
		 * </listing>
		 * 
		 * @param List of key-item-pairs to add to the map.
		 * @return map A new <code>Map</code> instance populated from the given arguments.
		 * @author Jens Struwe 21.04.2011
		 */
		public static function map(...args) : Map {
			var map : Map = new Map();
			args.unshift(map);
			Maps.addAll.apply(null, args);
			return map;
		}

		/**
		 * Creates, populates and returns a new <code>LinkedMap</code> instance.
		 * 
		 * <p>The arguments may be left out. In that case no item is added to the map.</p>
		 * 
		 * <p>The last argument is skipped if the size of arguments is not even.</p>
		 * 
		 * <listing>
				var map : Map = Maps.linkedMap(key1, item1, key2, item2, ...);
		 * </listing>
		 * 
		 * @param List of key-item-pairs to add to the map.
		 * @return map A new <code>LinkedMap</code> instance populated from the given arguments.
		 * @author Jens Struwe 21.04.2011
		 */
		public static function linkedMap(...args) : LinkedMap {
			var map : LinkedMap = new LinkedMap();
			args.unshift(map);
			Maps.addAll.apply(null, args);
			return map;
		}

		/**
		 * Creates, populates and returns a new <code>SortedMap</code> instance.
		 * 
		 * <p>The arguments may be left out. In that case no item is added to the map.</p>
		 * 
		 * <p>The last argument is skipped if the size of arguments is not even.</p>
		 * 
		 * <listing>
				var map : Map = Maps.sortedMap(key1, item1, key2, item2, ...);
		 * </listing>
		 * 
		 * @param List of key-item-pairs to add to the map.
		 * @return map A new <code>SortedMap</code> instance populated from the given arguments.
		 * @author Jens Struwe 21.04.2011
		 */
		public static function sortedMap(comparator : IComparator, ...args) : SortedMap {
			var map : SortedMap = new SortedMap(comparator);
			args.unshift(map);
			Maps.addAll.apply(null, args);
			return map;
		}
		
		/*
		 * Map Population
		 */

		/**
		 * Adds the supplied supplied list of key-item-pairs to the given map.
		 * 
		 * <p>The arguments may be left out. In that case no item is added to the map.</p>
		 * 
		 * <p>The last argument is skipped if the size of arguments is not even.</p>
		 * 
		 * <listing>
				Maps.populate(myMap, key1, item1, key2, item2, ...);
		 * </listing>
		 * 
		 * @param map The map to be populated.
		 * @param List of key-item-pairs to add to the map.
		 */
		public static function addAll(map : IMap, ...args) : void {
			for (var i : uint; i < args.length; i+=2) {
				if (i == args.length - 1) break;
				map.add(args[i], args[i + 1]);
			}
		}
		
	}
}
