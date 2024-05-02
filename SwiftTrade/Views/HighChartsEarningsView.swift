//
//  HighChartsEarningsView.swift
//  SwiftTrade
//
//  Created by Abhishek Kumar on 5/2/24.
//

import SwiftUI
import WebKit

struct HighChartsEarningsView: View {
    @StateObject var highChartsViewModel: HighChartsViewModel = HighChartsViewModel()
    
    var body: some View {
        if highChartsViewModel.isLoading {
            ProgressView()
        } else {
//            if let hourlyData = highChartsViewModel.hourlyModel {
//                HighChartsHourlyView(hourlyData: hourlyData)
//                    .onAppear(perform: {
//                        Task {
//                            await highChartsViewModel.getHourlyTimeseriesData()
//                        }
//                    })
//            }
//
//            if let ohlcData = highChartsViewModel.ohlcModel, let volumeData = highChartsViewModel.volumeModel {
//                HighChartsHistoricalView(ohlcData: ohlcData, volumeData: volumeData)
//                    .onAppear(perform: {
//                        Task {
//                            await highChartsViewModel.getHistoricalTimeseriesData()
//                        }
//                    })
//            }
//            
            VStack{
                if let recommendationData = highChartsViewModel.recommendationModel {
                    HighChartsRecommendationView(recommendationData: recommendationData)
                }
                
                if let earningsData = highChartsViewModel.earningsModel {
                    HCEarningsView(earningData: earningsData)
                }
            }
            .onAppear(perform: {
                Task {
//                    await highChartsViewModel.getHourlyTimeseriesData()
//                    await highChartsViewModel.getHistoricalTimeseriesData()
//                    await highChartsViewModel.getRecommendationsData()
//                    await highChartsViewModel.getEarningsData()
                    
                }
            })
        }
    }
}

#Preview {
    HighChartsEarningsView()
}

struct HCEarningsView: UIViewRepresentable {
    @ObservedObject var highChartsViewModel: HighChartsViewModel = HighChartsViewModel()
    var earningData: EarningsModel?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(earningData), let jsonString = String(data: jsonData, encoding: .utf8) {
            injectDataAndLoadContent(webView: webView, jsonData: jsonString)
        }
    }
    
    func injectDataAndLoadContent(webView: WKWebView, jsonData: String){
        print("earningData: \(jsonData)")
        
        let htmlContent: String =
    """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
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
        <script src="https://code.highcharts.com/modules/series-label.js"></script>
        <script src="https://code.highcharts.com/modules/exporting.js"></script>
        <script src="https://code.highcharts.com/modules/export-data.js"></script>
        <script src="https://code.highcharts.com/modules/accessibility.js"></script>
        
        
        <figure class="highcharts-figure">
            <div id="container"></div>
        </figure>
        
        
        <script>
        
        let dataObject = \(jsonData)
        const data = dataObject.period.map((period, index) => ({
            period: period,
            estimate: dataObject.estimate[index],
            surprise: dataObject.surprise[index],
            actual: dataObject.actual[index]
        }));
                        
        Highcharts.chart('container', {
          chart: {
                type: "spline",
              },
              credits: {
                enabled: false,
              },
              title: {
                text: "Historical EPS Surprises",
              },
              xAxis: {
                title: {
                  text: "",
                },
                categories: data.map(
                  (item) => `${item.period}<br>Surprise: ${item.surprise}`
                ),
              },
              yAxis: {
                title: {
                  text: "Quarterly EPS",
                },
              },
              series: [
                {
                  name: "Actual",
                  data: data.map((item) => item.actual),
                  color: "#7cb5ec",
                },
                {
                  name: "Estimate",
                  data: data.map((item) => item.estimate),
                  color: "#6B64B9",
                },
              ],
              plotOptions: {
                line: {
                  dataLabels: {
                    enabled: true,
                    format: "Surprise: {point.y:.4f}",
                  },
                  enableMouseTracking: true,
                },
              },

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
        var parent: HCEarningsView
        
        init(_ parent: HCEarningsView){
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
