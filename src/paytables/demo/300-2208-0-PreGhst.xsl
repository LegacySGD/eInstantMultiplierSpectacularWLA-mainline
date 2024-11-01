<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					var bonusTotal = 0; 
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var winningNums = getWinningNumbers(scenario);
						var bonusValue = getBonusValue(scenario);
						var outcomeNums = getOutcomeData(scenario, 0);
						var outcomePrizes = getOutcomeData(scenario, 1);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');
						var bonusMegaMatch = false;
						var bonusHyperSpin = false;

						// Output winning numbers table.
						var r = [];
						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
 						r.push('<tr><td class="tablehead" colspan="' + winningNums.length + '">');
 						r.push(getTranslationByName("winningNumbers", translations));
 						r.push('</td></tr>');
 						r.push('<tr>');
 						for(var i = 0; i < winningNums.length; ++i)
 						{
 							r.push('<td class="tablebody">');
 							r.push(winningNums[i]);
 							r.push('</td>');
 						}
 						r.push('</tr>');
 						r.push('</table>');

						// Output outcome numbers table.
 						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
						r.push('<tr>');
 						r.push('<td class="tablehead" width="15%">');
 						r.push(getTranslationByName("yourNumbers", translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" width="15%">');
 						r.push(getTranslationByName("boardValues", translations));
						r.push('</td>');
 						r.push('</tr>');
						for(var i = 0; i < outcomeNums.length; ++i)
						{
							r.push('<tr>');
							r.push('<td class="tablebody" width="15%">');
 							if(checkMatch(winningNums, outcomeNums[i]))
 							{
 								r.push(getTranslationByName("youMatched", translations) + ': ');
 							}
 							else if(instantWin(outcomeNums[i]))
 							{
 								r.push(getTranslationByName("instantWin", translations) + ': ');
 							}
							if (outcomeNums[i] == "Y")
							{
								bonusMegaMatch = true;
							}
							else if (outcomeNums[i] == "Z")
							{
								bonusHyperSpin = true;
							}
 							r.push(translateOutcomeNumber(outcomeNums[i], translations));
 							r.push('</td>');
 							r.push('<td class="tablebody" width="15%">');
 							r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, outcomePrizes[i])]);
							r.push('</td>');
 							r.push('</tr>');
						}
						r.push('</table>');
						r.push('</br>');

						if (bonusMegaMatch) 
						{
							var bonusData = getBonusData(scenario, 2);
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							r.push('<tr>');
 							r.push('<td class="tablehead" width="25%">');
 							r.push(getTranslationByName("bonusPrizesMM", translations));
 							r.push('</td>');
							r.push('</tr>');

							for (var i = 0; i < bonusData.length; ++i)
							{
								var MMData = bonusData[i].split(":");
								var counter = 0;
								for (var j = 0; j < 3; ++j)
								{
									counter = 1;
									for (var k = j+1; k < 5; ++k)
									{
										if (MMData[j] == MMData[k])
										{
											++counter;
										}
									}
									if (counter == 3)
									{
										r.push('<tr>');
										r.push('<td>');
										r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, MMData[j])]);
										r.push('</td>');
										r.push('</tr>');
									}
								}
							}
							r.push('</table>');
						}

						if (bonusHyperSpin) 
						{
							var bonusData = getBonusData(scenario, 3);
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							r.push('<tr>');
 							r.push('<td class="tablehead" width="20%">');
 							r.push(getTranslationByName("bonusPrizesHS", translations));
 							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spin", translations) + " 1");
 							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spin", translations) + " 2");
 							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spin", translations) + " 3");
 							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spin", translations) + " 4");
 							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spinTotal", translations));
 							r.push('</td>');
							r.push('</tr>');

							var HSTotal = 0;
							for (var i = 0; i < bonusData.length; ++i)
							{
								var HSData = bonusData[i].split(":");
								var counter = 0;
								r.push('<tr>');
								//r.push(bonusData[i]);
								r.push('<td>');
								r.push('</td>');
								for (var j = 0; j < 4; ++j)
								{
									if (HSData[j] == "0")
									{
										r.push('<td>');
										r.push(getTranslationByName("collect", translations));
										r.push('</td>');
									}
									else
									{
										counter = counter +  parseInt(HSData[j]);
										r.push('<td>');
										r.push(HSData[j]);
										r.push('</td>');
									}
								}
								r.push('<td>');
								r.push(counter);
								r.push('</td>');
								r.push('</tr>');
								HSTotal = HSTotal + counter;
							}
							r.push('<tr>');
							r.push('<td>');
							r.push(getTranslationByName("HSMultiplierTotal", translations) + ": " + HSTotal + "x");
							r.push('</td>');
							r.push('</tr>');
							r.push('<tr>');
							r.push('<td>');
							r.push(getTranslationByName("HSTotalWin", translations) + ": " + convertedPrizeValues[getPrizeNameIndex(prizeNames, getHSRef(HSTotal))]);
							r.push('</td>');
							r.push('</tr>');

							r.push('</table>');
						}
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 								r.push('</td>');
 								r.push('</tr>');
							}
							r.push('</table>');
						}
						r.push('</br>');
						return r.join('');
					}

					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");


						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}

						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}

					function getBonusValue(scenario)
					{
						var numsData = scenario.split("|")[2];
						return numsData;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						var temp = '';

						for(var i = 0; i < outcomePairs.length; ++i)
						{
							switch (index)
							{
								case 0 :
									temp = outcomePairs[i].split(":")[0];
									result.push(temp);
									break;
								case 1 :
									temp = outcomePairs[i].split(":")[1];
									result.push(temp.slice(0,1));
									break;
							//	case 2 :
							//		temp = outcomePairs[i].split(":")[1];
							//		result.push(temp.slice(1));
							//		bonusTotal += Number(temp.slice(1));
							//		break;
							}
						}
						return result;
					}

					function getBonusData(scenario, index)
					{
						var result = [];
						var bonusDataSet = scenario.split("|")[index];
						var bonusPlays = bonusDataSet.split(",");
						for(var i = 0; i < bonusPlays.length; ++i)
						{
							switch (index)
							{
								case 2 :
									result.push(bonusPlays[i]);
									break;
								case 3 :
									result.push(bonusPlays[i]);
									break;
							}
						}
						return result;
					}

					function getHSRef(HSVal)
					{
						var HSValues = [10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450, 500];
						var HSRef = ["H27","H26","H25","H24","H23","H22","H21","H20","H19","H18","H17","H16","H15","H14","H13","H12","H11","H10","H9","H8","H7","H6","H5","H4","H3","H2","H1"];
						for (var i = 0; i < HSValues.length; ++i)
						{
							if (HSValues[i] == HSVal)
							{
								var index = i;
							}
						}
						return HSRef[index];
					}

					// Input: 'X', 'E', or number (e.g. '23')
					// Output: translated text or number.
					function translateOutcomeNumber(outcomeNum, translations)
					{
						if (outcomeNum == "101")
						{
							return (""); 
						}
						else if (outcomeNum == "102")
						{
							return ("x2");
						}
						else if (outcomeNum == "103")
						{
							return ("x5");
						}
						else if (outcomeNum == "104")
						{
							return ("x10");
						}
						else if (outcomeNum == "105")
						{
							return ("x20");
						}
						else if (outcomeNum == "106")
						{
							return ("x50");
						}
						else if (outcomeNum == "107")
						{
							return ("x100");
						}
						else if (outcomeNum == "108")
						{
							return ("x200");
						}
						else if (outcomeNum == "Y")
						{
							return getTranslationByName("triggerMegaMatch", translations);
						}
						else if (outcomeNum == "Z")
						{
							return getTranslationByName("triggerHyperSpin", translations);
						}
						else
						{
							return outcomeNum;
						}
					}

					// Input: List of winning numbers and the number to check
					// Output: true if number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i < winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						return false;
					}

					// Input: number to check
					// Output: true if number is instant win or false if not
					function instantWin(boardNum)
					{
						if(boardNum == "101" || boardNum == "102" || boardNum == "103" || boardNum == "104" || boardNum == "105" || boardNum == "106" || boardNum == "107" || boardNum == "108")
						{
							return true;
						}
						return false;
					}

					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}

					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
