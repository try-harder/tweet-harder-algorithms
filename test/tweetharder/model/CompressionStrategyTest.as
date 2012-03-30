package tweetharder.model {

	import asunit.framework.TestCase;

	public class CompressionStrategyTest extends TestCase {
		private var instance:CompressionStrategy;

		public function CompressionStrategyTest(methodName:String=null) {
			super(methodName)
		}

		override protected function setUp():void {
			super.setUp();
			instance = new CompressionStrategy();
		}

		override protected function tearDown():void {
			super.tearDown();
			instance = null;
		}

		public function testInstantiated():void {
			assertTrue("instance is CompressionStrategy", instance is CompressionStrategy);
		}

		public function testFailure():void {
			assertTrue("Failing test", true);
		}
		
		protected function createSpoofSQL():SpoofSQL
		{
			const spoofSQL:SpoofSQL = new SpoofSQL();
			spoofSQL.addTerm("Quick Brown")
			spoofSQL.addTerm("Brown Fox")
			spoofSQL.addTerm("Fox and Hound")
			spoofSQL.addTerm("Over the hill")
			spoofSQL.addTerm("Over the")
			spoofSQL.addTerm("Over")
			spoofSQL.addTerm("How Now Brown Cow")
			spoofSQL.addTerm("Brown")
			spoofSQL.addTerm("Browning")
			spoofSQL.addTerm("Fox")
			spoofSQL.addTerm("MrBrown")
			spoofSQL.addTerm("the")
			spoofSQL.addTerm("Kill the Fox");
			spoofSQL.addTerm("Raindrops on roses");
			spoofSQL.addTerm("whiskers on kittens");
			spoofSQL.addTerm("roses and whiskers on");
			spoofSQL.addTerm("Raindrops");
			spoofSQL.addTerm("and");
			spoofSQL.addTerm("on");
			spoofSQL.addTerm("kittens");
			
			return spoofSQL;
		}
		
		public function test_can_find_3_unique_words():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "MrBrown Fox Over";
			const expected:Vector.<String> = new <String>["MrBrown", "Fox", "Over"];
			const result:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
			assertEqualsVectorsIgnoringOrder("Can find 3 unique words", expected, result);
		}
		
		public function test_can_split_3_words_into_pair_and_single():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Over the Fox";
			const expected:Vector.<String> = new <String>["Over the", "Fox"];
			const result:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
			
			assertEqualsVectorsIgnoringOrder("Can split 3 words into pair and single", expected, result);
		}
		
		public function test_can_split_6_words_into_four_and_two_singles():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Over How Now Brown Cow Fox";
			const expected:Vector.<String> = new <String>["Over", "How Now Brown Cow", "Fox"];
			const result:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
			
			assertEqualsVectorsIgnoringOrder("Can split 6 words into four and single", expected, result);
		}

		public function test_can_split_6_words_into_two_threes():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Over the hill Kill the Fox";
			const expected:Vector.<String> = new <String>["Over the hill", "Kill the Fox"];
			const result:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
			
			assertEqualsVectorsIgnoringOrder("Can split 6 words into two threes", expected, result);
		}
		
		public function test_gives_back_a_list_of_unmatched_terms():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Over Surf's up How Now Brown Cow Happy Birthday to You Fox Cat";
			const expected:Vector.<String> = new <String>["Surf's up", "Happy Birthday to You", "Cat"];
			const result:Vector.<String> = unknownTermsFrom(tweet, spoofSQL);
			
			assertEqualsVectorsIgnoringOrder("Finds correct list of unknown words", expected, result);
		}
		
		public function test_a_whole_unmatched_sentence():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "The Cat in The Hat is a Dr Zeuss Book - Awesome!"
			const expected:Vector.<String> = new <String>["The Cat in The Hat is a Dr Zeuss Book - Awesome!"];
			const result:Vector.<String> = unknownTermsFrom(tweet, spoofSQL);

			assertEqualsVectorsIgnoringOrder("Finds a whole unmatched sentence", expected, result);
		}
		
		public function test_translates_a_matched_sentence_efficiently():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Over How Now Brown Cow Fox";
			const expected:Vector.<uint> = new <uint>[6,7,10];
			const result:Vector.<uint> = translateTweet(tweet, spoofSQL);
			
			assertEqualsVectorsIgnoringOrder("Translates a matched sentence efficiently", expected, result);
		}
		
		public function test_translates_a_matched_sentence_preserving_order():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Fox How Now Brown Cow Over";
			const expected:Vector.<uint> = new <uint>[10,7,6];
			const result:Vector.<uint> = translateTweet(tweet, spoofSQL);
			
			assertEqualsVectors("Translates a matched sentence preserving order", expected, result);
		}
		
		public function test_annealing_finds_efficent_solution():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const tweet:String = "Raindrops on roses and whiskers on kittens";
			const expected:Vector.<String> = new <String>["Raindrops on roses", "and", "whiskers on kittens"];
			const anneallingStrength:Number = 0.8;
			var result:Vector.<String>;
			
			const iLength:uint = 10;
			for (var i:uint = 0; i < iLength; i++)
			{
				result = optimallyTokeniseTweet(tweet, spoofSQL, anneallingStrength);
				if(result.length == 3)
					break;
			}
			
			assertEqualsVectors("Annealing finds efficent solution", expected, result);
		}
		
		public function test_findACharacterNotUsedIn_returns_earliest_unused_character():void {
			
			const subject:String = String.fromCharCode(34) + String.fromCharCode(35) + String.fromCharCode(36) + "abcdefghijklmnop";
			
			assertEquals("Find unused character returns earliest unused character", String.fromCharCode(37), findACharacterNotUsedIn(subject));
		}
		
		protected function translateTweet(tweet:String, spoofSQL:SpoofSQL):Vector.<uint>
		{
			const tokens:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
			const translation:Vector.<uint> = new <uint>[];
			const iLength:uint = tokens.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				translation.push(spoofSQL.lookUpKeyFromTerm(tokens[i]))
			}
			
			return translation;
		}
		
		protected function orderTokensFor(tweet:String, tokens:Vector.<String>):Vector.<String>
		{
			var workingCopyOfTweet:String = new String(tweet);
			var tokensByPosition:Array = [];
			var token:String;
			var spacer:String = "";
			const spacerChar:String = findACharacterNotUsedIn(tweet);
			const iLength:uint = tokens.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				token = tokens[i];
				while(workingCopyOfTweet.indexOf(token) != -1)
				{
					tokensByPosition[tweet.indexOf(token)] = token;
					
					while(spacer.length < token.length)
						spacer+= spacerChar;
					
					workingCopyOfTweet = workingCopyOfTweet.replace(token, spacer.substr(0, token.length));
				}
			}
			
			tokensByPosition = tokensByPosition.filter(itemNotNull);
			return Vector.<String>(tokensByPosition);
		}
		
		protected function itemNotNull(item:*, index:int, array:Array):Boolean
		{
			return item != null;
		}
		
		protected function unknownTermsFrom(tweet:String, spoofSQL:SpoofSQL):Vector.<String>
		{
			const tokens:Vector.<String> = tokeniseTweet(tweet, spoofSQL);
						
			const separatorChar:String = findACharacterNotUsedIn(tweet);			
			var subject:String = tweet;
			const iLength:uint = tokens.length;
			
			for (var i:uint = 0; i < iLength; i++)
			{
				subject = subject.replace(tokens[i], separatorChar);
			}
			
			const firstWordPattern:RegExp = new RegExp("^" + regexEscape(separatorChar) + " ");
			const lastWordPattern:RegExp = new RegExp(" " + regexEscape(separatorChar) + "$");
			
			subject = subject.replace(firstWordPattern, "");
			subject = subject.replace(lastWordPattern, "");
						
			return Vector.<String>(subject.split(" " + separatorChar + " "));
		}
		
		protected function regexEscape(char:String):String
		{
			const regexSpecialChars:String = "[\^$.|?*+()";
			if(regexSpecialChars.indexOf(char) > -1)
				return String.fromCharCode(92) + char;
			return char;
		}
		
		protected function optimallyTokeniseTweet(tweet:String, spoofSQL:SpoofSQL, anneallingStrength:Number):Vector.<String>
		{
			var tokens:Vector.<String> = tokeniseTweet(tweet, spoofSQL, 1);
			var optimumResult:Vector.<String> = tokens;
			
			if(anneallingStrength <= 0 || anneallingStrength >= 1)
				return optimumResult;
			
			while(Math.random() < anneallingStrength)
			{
				tokens = tokeniseTweet(tweet, spoofSQL, anneallingStrength);
				if(tokens.length < optimumResult.length)
					optimumResult = tokens;
				anneallingStrength *= anneallingStrength;
			}
			
			return optimumResult;
		}
		
		protected function tokeniseTweet(tweet:String, spoofSQL:SpoofSQL, groupSizeFactor:Number = 1):Vector.<String>
		{			
			const tweetWords:Vector.<String> = Vector.<String>(tweet.split(" "));
 			
			const interestingTerms:Vector.<String> = findInterestingTermsFor(tweetWords, spoofSQL);
			const tokens:Vector.<String> = new <String>[];
			
			const maxTermLengthInHaystack:uint = spoofSQL.findMaxWordCount(interestingTerms);
			
			var groupSize:uint = Math.min(tweetWords.length, maxTermLengthInHaystack);
			
			if(groupSizeFactor < 1)
				groupSize = Math.ceil(groupSize * groupSizeFactor);
			
			const iLength:uint = groupSize;
			var wordWindow:Vector.<String>;
			var wordGroup:String;
			var matches:Vector.<String>;
			
			for (var i:uint = 0; i < iLength; i++)
			{
				for (var j:int = 0; j <= (tweetWords.length - (groupSize)); j++)
				{
					wordWindow = tweetWords.slice(j, groupSize+j);
					wordGroup = wordWindow.join(" ");
					matches = spoofSQL.runQuery(new RegExp("^"+wordGroup+"$"), interestingTerms);
					if(matches.length == 1)
					{
						tokens.push(matches[0]);
						tweetWords.splice(j, groupSize);
						j--;
					}
				} 
				groupSize--;
			}
			
			return orderTokensFor(tweet, tokens);
		}
		
		protected function findInterestingTermsFor(tweetWords:Vector.<String>, spoofSQL:SpoofSQL):Vector.<String>
		{
			var receivedTerms:Vector.<String> = new <String>[];
			const iLength:uint = tweetWords.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				receivedTerms = receivedTerms.concat(spoofSQL.searchFor(tweetWords[i]));
			}
			
			const uniqueTerms:Vector.<String> = removeDuplicates(receivedTerms);
			return uniqueTerms;
		}
		
		protected function removeDuplicates(stringVector:Vector.<String>):Vector.<String>
		{
			const uniqueItems:Vector.<String> = new <String>[];
			const iLength:uint = stringVector.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				if(uniqueItems.indexOf(stringVector[i]) == -1)
				{
					uniqueItems.push(stringVector[i]);
				}
			}
			return uniqueItems;
		}
		
		protected function findACharacterNotUsedIn(subject:String):String
		{
			const charNumber:uint = 34;
			var char:String;
			while(char = String.fromCharCode(charNumber))
			{
				if(subject.indexOf(char) == -1)
					return char;
			
				charNumber++;
			}
			return "";
		}
		
		public function test_when_spoofSQL_queried_for_brown_returns_all_items_containing_brown():void {
			
			const spoofSQL:SpoofSQL = createSpoofSQL();
			
			const expectedTerms:Vector.<String> = new <String>["Quick Brown", "Brown Fox", "How Now Brown Cow", "Brown"];
			var receivedTerms:Vector.<String> = 	spoofSQL.runQuery(/ Brown$/) ;
			receivedTerms = receivedTerms.concat( 	spoofSQL.runQuery(/^Brown /) );
			receivedTerms = receivedTerms.concat( 	spoofSQL.runQuery(/^Brown$/) );
			receivedTerms = receivedTerms.concat( 	spoofSQL.runQuery(/ Brown /) );
			
			assertEqualsVectorsIgnoringOrder("When spoofSQL queried for brown returns all items containing brown", expectedTerms, receivedTerms);
		}
	}
}

import flash.utils.Dictionary;

class SpoofSQL
{
	private var _terms:Vector.<String> = new Vector.<String>();
	private var _key:uint = 0;
	private var _keysByTerm:Dictionary = new Dictionary();
	
	public function addTerm(term:String):void
	{
		_key++;
		_terms.push(term);
		_keysByTerm[term] = _key;
	}
	
	public function findMaxWordCount(ofTerms:Vector.<String> = null):uint
	{
		if(!ofTerms)
			ofTerms = _terms;
			
		var maxWords:uint = 0;
		var termWords:Array;
		const iLength:uint = ofTerms.length;
		for (var i:uint = 0; i < iLength; i++)
		{
			termWords = ofTerms[i].split(" ");
			if(termWords.length > maxWords)
				maxWords = termWords.length;
		}
		
		return maxWords;
	}
	
	public function searchFor(term:String, onTerms:Vector.<String> = null):Vector.<String>
	{
		var receivedTerms:Vector.<String> = new <String>[];
		receivedTerms = receivedTerms.concat(  	runQuery(new RegExp(" " + term + "$")));
		receivedTerms = receivedTerms.concat( 	runQuery(new RegExp("^" + term + " ")));
		receivedTerms = receivedTerms.concat( 	runQuery(new RegExp("^" + term + "$")));
		receivedTerms = receivedTerms.concat( 	runQuery(new RegExp(" " + term + " ")));
		return receivedTerms;
	}
	
	public function runQuery(query:RegExp, onTerms:Vector.<String> = null):Vector.<String>
	{
		if(!onTerms)
			onTerms = _terms;
			
		const matches:Vector.<String> = new <String>[];
		const iLength:uint = onTerms.length;
		for (var i:uint = 0; i < iLength; i++)
		{
			if(onTerms[i].search(query) > -1)
				matches.push(onTerms[i]);
		}
		
		return matches;
	}
	
	public function lookUpKeyFromTerm(term:String):uint
	{
		return _keysByTerm[term];
	}
}