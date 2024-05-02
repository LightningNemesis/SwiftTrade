//
//  HighChartsHistoricalView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import SwiftUI
import WebKit
import Foundation

struct HighChartsHistoricalView: UIViewRepresentable {
    var ohlcData: [OhlcModel] = []
    var volumeData: [VolumeModel] = []
    var ticker: String
    
    @ObservedObject var highChartsViewModel: HighChartsViewModel = HighChartsViewModel()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let ohlcDataString = ohlcData.map { "[\($0.t), \($0.o), \($0.h), \($0.l), \($0.c)]" }.joined(separator: ", ")
        let volumeDataString = volumeData.map { "[\($0.t), \($0.v)]" }.joined(separator: ", ")
        
        print("ohlcDataString:\t \(ohlcDataString)\n")
        print("VolumeDataString:\t \(volumeDataString)\n")
        

        let htmlContent: String =
    """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            .highcharts-figure,
            .highcharts-data-table table {
                min-width: 360px;
                max-width: 800px;
                margin: 1em auto;
            }
            
            .highcharts-data-table table {
                font-family: Verdana, sans-serif;
                border-collapse: collapse;
                border: 1px solid #ebebeb;
                margin: 10px auto;
                text-align: center;
                width: 100%;
                max-width: 500px;
            }
            
            .highcharts-data-table caption {
                padding: 1em 0;
                font-size: 1.2em;
                color: #555;
            }
            
            .highcharts-data-table th {
                font-weight: 600;
                padding: 0.5em;
            }
            
            .highcharts-data-table td,
            .highcharts-data-table th,
            .highcharts-data-table caption {
                padding: 0.5em;
            }
            
            .highcharts-data-table thead tr,
            .highcharts-data-table tr:nth-child(even) {
                background: #f8f8f8;
            }
            
            .highcharts-data-table tr:hover {
                background: #f1f7ff;
            }
        </style>
        
        <script src="https://code.highcharts.com/stock/highstock.js"></script>
        <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
        <script src="https://code.highcharts.com/stock/modules/accessibility.js"></script>
        <script src="https://code.highcharts.com/stock/modules/drag-panes.js"></script>
        <script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
        <script src="https://code.highcharts.com/stock/indicators/indicators.js"></script>
        <script src="https://code.highcharts.com/stock/indicators/volume-by-price.js"></script>
        
        <figure class="highcharts-figure">
            <div id="container"></div>
        </figure>
        
        <script>
        const groupingUnits = [
          [
            "week", // unit name
            [1], // allowed multiples
          ],
          ["month", [1, 2, 3, 4, 6]],
        ];
                
        Highcharts.stockChart('container', {
          rangeSelector: {
            enabled: true,
            selected: 2,
            buttons: [
              { type: "month", count: 1, text: "1m" },
              { type: "month", count: 3, text: "3m" },
              { type: "month", count: 6, text: "6m" },
              { type: "ytd", text: "YTD" },
              { type: "year", count: 1, text: "1y" },
              { type: "all", text: "All" },
            ],
          },
          navigator: {
            enabled: true, // Make sure the navigator is enabled
          },
          title: {
            text: '\(ticker) Stock Price'
          },
          subtitle: {
            text: "With SMA and Volume by Price technical indicators",
          },
          xAxis: {
            type: "datetime",
            labels: {
              formatter: function () {
                return Highcharts.dateFormat("%e %b", this.value); // For hour:minute format
              },
            },
          },
          yAxis: [
            {
              opposite: true,
              startOnTick: false,
              endOnTick: false,
              labels: {
                align: "right",
                x: -3,
              },
              title: {
                text: "OHLC",
              },
              height: "60%",
              lineWidth: 2,
              resize: {
                enabled: true,
              },
            },
            {
              opposite: true,
              labels: {
                align: "right",
                x: -3,
              },
              title: {
                text: "Volume",
              },
              top: "65%",
              height: "35%",
              offset: 0,
              lineWidth: 2,
            },
          ],

          tooltip: {
            split: true,
          },
          series: [
                {
                  type: "candlestick",
                  name: "AAPL",
                  id: "aapl",
                  zIndex: 2,
                  data: [\(ohlcDataString)],
                 },
                 {
                   type: "column",
                   name: "Volume",
                   id: "volume",
                   data: [\(volumeDataString)],
                    yAxis: 1,
                  },
                {
                    type: "vbp",
                    linkedTo: "aapl",
                    params: {
                      volumeSeriesID: "volume",
                    },
                    dataLabels: {
                      enabled: false,
                    },
                    zoneLines: {
                      enabled: false,
                    },
                },
               {
                 type: "sma",
                 linkedTo: "aapl",
                 zIndex: 1,
                 marker: {
                   enabled: false,
                 },
               },
            ],

            });
        </script>
        
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HighChartsHistoricalView
        
        init(_ parent: HighChartsHistoricalView){
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Web content loaded")
        }
        
        // Implement other delegate methods as needed, for example:
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed to load web content: \(error.localizedDescription)")
        }
    }
}

//#Preview {
//    HighChartsHistoricalView()
//}
