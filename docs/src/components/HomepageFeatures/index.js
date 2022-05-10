import React from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

const FeatureList = [
  {
    title: '🧘 Offline-first',
    description: "Unruffled lets you design Flutter apps that run perfectly offline. Don't worry, we manage everything for you including connectivity issues & retries !"
  },
  {
    title: '🍭 Highly customizable',
    description: "Your API is very customized or non-standard ? Unruffled can handle it ! You can create any custom calls, responses & behavior."
  },
  {
    title: '🌍 Dart package',
    description: "Unruffled is a Dart package, it supports all Flutter platforms. iOS, Android, Web, MacOS, Windows & Linux have no secrets for you now."
  },
];

function Feature({title, description}) {
  return (
    <div className={clsx('col col--4')}>
      <div className="text--left padding-horiz--md">
        <h2>{title}</h2>
        <p>{description}</p>
      </div>
    </div>
  );
}

export default function HomepageFeatures() {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {FeatureList.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
