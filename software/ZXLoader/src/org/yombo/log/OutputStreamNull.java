/**
 * 
 *  Copyright (C) 2010  Juan Jose Luna Espinosa juanjoluna@gmail.com

 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, version 3 of the License.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *  
 *  
 * Output stream que no hace nada
 */
package org.yombo.log;

import java.io.OutputStream;

public class OutputStreamNull extends OutputStream {

    public OutputStreamNull() {
        // Nada que hacer
    }

    public void close() {
        // Nada que hacer
    }

    public void flush() {
        // Nada que hacer
    }
    
    public void write( byte[] b ) {
        // Nada que hacer
    }
    
    public void write( byte[] b, int off, int len ) {
        // Nada que hacer
    }
    
    public void write( int b ) {
        // Nada que hacer
    }
}