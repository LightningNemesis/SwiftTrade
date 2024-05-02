//
//  HighChartsHourlyView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import SwiftUI
import WebKit
import Foundation

struct HighChartsHourlyView: UIViewRepresentable {
    var hourlyData: [HourlyModel]  // Array of HourlyModel
    var ticker: String
    
    @ObservedObject var highChartsViewModel: HighChartsViewModel = HighChartsViewModel()
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let dataString = hourlyData.map { "[\($0.t), \($0.c)]" }.joined(separator: ", ")
//        print("Hourly data: \(dataString)")
        
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
    
    <script src="https://code.highcharts.com/highcharts.js"></script>
    <script src="https://code.highcharts.com/modules/series-label.js"></script>
    <script src="https://code.highcharts.com/modules/exporting.js"></script>
    <script src="https://code.highcharts.com/modules/export-data.js"></script>
    <script src="https://code.highcharts.com/modules/accessibility.js"></script>

    <figure class="highcharts-figure">
        <div id="container"></div>
    </figure>
    
    <script>
    Highcharts.chart('container', {
        title: {
            text: '\(ticker) Hourly Price Validation',
        },
        xAxis: {
            type: "datetime",
            crosshair: true,
            labels: {
                formatter: function() {
                    return Highcharts.dateFormat("%H:%M", this.value);
                },
            },
            tooltip: {
                formatter: function() {
                    return Highcharts.dateFormat('%Y-%m-%d %H:%M', this.value);
                }
            }
        },
        yAxis: {
            title: {
                text: "",
            },
            opposite: true,
            labels: {
                formatter: function() {
                    return this.value.toFixed(2);
                }

            }
        },
        tooltip: {
            split: true,
            shared: true,
            valueDecimals: 2,
        },
      formatter: function() {
                return 'AAPL: ' + this.y; // Add 'AAPL: ' prefix only in tooltip
            },
        legend: { enabled: false },
        plotOptions: {
            series: {
                marker: {
                    enabled: false,
                },
            },
        },
        series: [{
            name: '',
            data: [\(dataString)]
        }],

        responsive: {
                rules: [{
                    condition: {
                        maxWidth: 500
                    },
                    chartOptions: {
                        legend: {
                            layout: 'horizontal',
                            align: 'center',
                            verticalAlign: 'bottom'
                        }
                    }
                }]
            }
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
        var parent: HighChartsHourlyView
        
        init(_ parent: HighChartsHourlyView){
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
//    HighChartsHourlyView(hourlyData: [])
//}
