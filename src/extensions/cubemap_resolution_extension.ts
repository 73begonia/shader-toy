'use strict';

import { WebviewExtension } from './webview_extension';

export class CubemapResolutionExtension implements WebviewExtension {
    private cubemapResolution: number;

    constructor(cubemapResolution: number) {
        this.cubemapResolution = cubemapResolution;
    }

    public generateContent(): string {
        return `${this.cubemapResolution}`;
    }
}
