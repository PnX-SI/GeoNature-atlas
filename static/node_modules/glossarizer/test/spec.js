describe("Glossarizr", function() {

    var fixture, terms, exclude

    beforeEach(function(){

        fixture = $('<div class="content"><p>Hey its the god of death,  Power of Attorney (POA) but he is travelling to the death star</p></div>')
    })


    describe('should load the `glossary.json` file', function(){
        
        beforeEach(function (done) {            

            fixture.glossarizer({
                sourceURL: '../glossary.json',
                callback: function(){                

                    done();
                    
                }
            });
        });


        it('should markup the word `death`', function(){
            
            expect(fixture.find('abbr').eq(0).text()).toBe('death')

        })

        it('should markup the word `Power of Attorney (POA)`', function(){
            
            expect(fixture.find('abbr').eq(1).text()).toBe('Power of Attorney (POA)')

        })

        it('should not markup the word `death star`', function(){
            
            expect(fixture.find('abbr').eq(':last-child').text()).not.toBe('death star')
            
        })
        
    })
});