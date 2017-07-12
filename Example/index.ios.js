/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  NativeModules,
  NativeEventEmitter
} from 'react-native';
import AirPlay from 'react-native-airplay-btn'

const airPlayEvt = new NativeEventEmitter(NativeModules.AirPlay);

class Example extends Component {

  constructor() {
    super(props);
    this.state = {
      airPlayAvailable: false,
      airPlayConnected: false,
    }
  }

  componentDidMount() {
    AirPlay.startScan()
    this.airPlayAvailable = airPlayEvt.addListener('airplayAvailable', devices => this.setState({
          airPlayAvailable: devices.available,
    })); --> returns a boolean

    this.airPlayConnected = airPlayEvt.addListener('airplayConnected', devices => this.setState({
          airPlayConnected: devices.connected,
    })); --> returns a boolean
  }

  componentWillUnmount() {
    this.airPlayAvailable.remove();
    this.airPlayConnected.remove();
  }

  render() {
    return (
      <View style={styles.container}>
        {this.state.airPlayAvailable &&
          <AirPlay.Button style={styles.button} />
        }
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#333333',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
  button: {
    width: 40,
    height: 40,
    justifyContent: 'center',
    alignItems: 'center'
  }
});

AppRegistry.registerComponent('Example', () => Example);
