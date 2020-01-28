const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const { IgnorePlugin } = require('webpack');


module.exports = (env, options) => ({
  externals: function (context, request, callback) {
    if (/xlsx|canvg|pdfmake/.test(request)) {
      return callback(null, "commonjs " + request);
    }
    callback();
  },
  resolve: {
    alias: {
      pace: 'pace-progress'
    }
  },
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    "./js/app.js": glob.sync("./vendor/**/*.js").concat(["./js/app.js"])
  },
  output: {
    filename: "app.js",
    path: path.resolve(__dirname, "../priv/static/js")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.scss$/,
        use: [
          MiniCssExtractPlugin.loader,
          { loader: "css-loader" },
          { loader: "sass-loader" }
        ]
      }
    ]
  },
  plugins: [
    new IgnorePlugin(/^\.\/locale$/, /moment$/),
    new MiniCssExtractPlugin({ filename: "../css/app.css" }),
    new CopyWebpackPlugin([{ from: "static/", to: "../" }])
  ]
});
