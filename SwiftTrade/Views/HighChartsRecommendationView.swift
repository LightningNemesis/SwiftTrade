//
//  HighChartsRecommendationView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import SwiftUI
import WebKit
import Foundation

struct HighChartsRecommendationView: UIViewRepresentable {
    @ObservedObject var highChartsViewModel: HighChartsViewModel = HighChartsViewModel()
    var recommendationData: RecommendationModel?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(recommendationData), let jsonString = String(data: jsonData, encoding: .utf8) {
            injectDataAndLoadContent(webView: webView, jsonData: jsonString)
        }
    }
    
    func injectDataAndLoadContent(webView: WKWebView, jsonData: String){
//        print("Recommendations Data: \(jsonData)")
        
        let htmlContent: String =
    """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
        #container {
          height: 400px;
        }

        .highcharts-figure,
        .highcharts-data-table table {
          min-width: 310px;
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
        
        <script src="https://code.highcharts.com/highcharts.js"></script>
        <script src="https://code.highcharts.com/modules/exporting.js"></script>
        <script src="https://code.highcharts.com/modules/export-data.js"></script>
        <script src="https://code.highcharts.com/modules/accessibility.js"></script>
        
        <figure class="highcharts-figure">
        <div id="container"></div>
        <p class="highcharts-description">
        
        <script>
        
        let data = \(jsonData)
        
        const groupingUnits = [
          [
            "week", // unit name
            [1], // allowed multiples
          ],
          ["month", [1, 2, 3, 4, 6]],
        ];
                
        Highcharts.chart('container', {
          chart: {
                type: "column",
              },
              credits: {
                enabled: false, // This will remove the Highcharts.com watermark
              },

              title: {
                text: "Recommendation Trends",
              },
              xAxis: {
                labels: {
                  formatter: function () {
                    return Highcharts.dateFormat("%Y-%m", new Date(this.value)); // Format the date as "YYYY-MM"
                  },
                },
                categories: data.period,
              },
              yAxis: {
                min: 0,
                title: {
                  text: "# Analysis",
                },
                stackLabels: {
                  enabled: false,
                  style: {
                    fontWeight: "bold",
                    color: "gray",
                  },
                },
              },
              legend: {
                align: "center",
                verticalAlign: "bottom",
                backgroundColor: "#f8f8f8",
                borderColor: "none",
                borderWidth: 1,
                shadow: false,
              },
              tooltip: {
                headerFormat: "<b>{point.x}</b><br/>",
                pointFormat: "{series.name}: {point.y}<br/>Total: {point.stackTotal}",
              },
              plotOptions: {
                column: {
                  stacking: "normal",
                  dataLabels: {
                    enabled: true,
                  },
                },
              },
              series: [
                  {
                    name: 'Strong Buy',
                    data: data.strongBuy,
                    color: '#177B40',
                  },
                {
                name: 'Buy',
                data: [11,12,12,12],
                color: '#20C15D',
              },
              {
                name: 'Hold',
                data: data.hold,
                color: '#C2951D',
              },
              {
                name: 'Sell',
                data: data.sell,
                color: '#F25E67',
              },
              {
                name: 'Strong Sell',
                data: data.strongSell,
                color: '#8B3A33',
              },
                ]

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
        var parent: HighChartsRecommendationView
        
        init(_ parent: HighChartsRecommendationView){
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

#Preview {
    HighChartsRecommendationView()
}
